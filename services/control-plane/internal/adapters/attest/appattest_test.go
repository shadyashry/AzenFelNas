package attest_test

import (
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"crypto/sha256"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/asn1"
	"encoding/binary"
	"errors"
	"math/big"
	"testing"
	"time"

	"github.com/fxamacker/cbor/v2"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/attest"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/memory"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
)

const appID = "TEAMID1234.app.dailymuslim"

// device simulates an iPhone's App Attest key under a test CA standing in
// for Apple's (the real root is owner-supplied configuration, §15 D86).
type device struct {
	t      *testing.T
	key    *ecdsa.PrivateKey
	keyID  []byte
	root   *x509.Certificate
	rootK  *ecdsa.PrivateKey
	inter  *x509.Certificate
	interK *ecdsa.PrivateKey
}

func newCert(t *testing.T, tmpl, parent *x509.Certificate, pub, signer any) *x509.Certificate {
	t.Helper()
	der, err := x509.CreateCertificate(rand.Reader, tmpl, parent, pub, signer)
	if err != nil {
		t.Fatal(err)
	}
	c, err := x509.ParseCertificate(der)
	if err != nil {
		t.Fatal(err)
	}
	return c
}

func mustKey(t *testing.T) *ecdsa.PrivateKey {
	t.Helper()
	k, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		t.Fatal(err)
	}
	return k
}

func newDevice(t *testing.T) *device {
	d := &device{t: t, key: mustKey(t), rootK: mustKey(t), interK: mustKey(t)}
	ca := func(serial int64, cn string) *x509.Certificate {
		return &x509.Certificate{
			SerialNumber: big.NewInt(serial), Subject: pkix.Name{CommonName: cn},
			NotBefore: now.Add(-time.Hour), NotAfter: now.Add(24 * time.Hour),
			IsCA: true, BasicConstraintsValid: true, KeyUsage: x509.KeyUsageCertSign,
		}
	}
	d.root = newCert(t, ca(1, "Test App Attestation Root CA"), ca(1, "Test App Attestation Root CA"), &d.rootK.PublicKey, d.rootK)
	d.inter = newCert(t, ca(2, "Test App Attestation CA 1"), d.root, &d.interK.PublicKey, d.rootK)
	point, err := d.key.PublicKey.Bytes()
	if err != nil {
		t.Fatal(err)
	}
	sum := sha256.Sum256(point)
	d.keyID = sum[:]
	return d
}

func authenticatorData(counter uint32, aaguid, credID []byte, app string) []byte {
	rp := sha256.Sum256([]byte(app))
	b := append(rp[:], 0x40)
	b = binary.BigEndian.AppendUint32(b, counter)
	if aaguid != nil {
		b = append(b, aaguid...)
		b = binary.BigEndian.AppendUint16(b, uint16(len(credID))) //nolint:gosec // G115: test key ids are 32 bytes
		b = append(b, credID...)
	}
	return b
}

// attestation returns an attestation object for binding.
func (d *device) attestation(binding [32]byte, mutate func(authData *[]byte, nonce *[]byte)) []byte {
	cdh := sha256.Sum256(binding[:])
	authData := authenticatorData(0, attest.AAGUIDProduction, d.keyID, appID)
	nonceIn := append(append([]byte{}, authData...), cdh[:]...)
	sum := sha256.Sum256(nonceIn)
	nonce := sum[:]
	if mutate != nil {
		mutate(&authData, &nonce)
	}
	ext, err := asn1.Marshal(struct {
		Nonce []byte `asn1:"explicit,tag:1"`
	}{nonce})
	if err != nil {
		d.t.Fatal(err)
	}
	leaf := newCert(d.t, &x509.Certificate{
		SerialNumber: big.NewInt(3), Subject: pkix.Name{CommonName: "credential"},
		NotBefore: now.Add(-time.Hour), NotAfter: now.Add(24 * time.Hour),
		ExtraExtensions: []pkix.Extension{{Id: asn1.ObjectIdentifier{1, 2, 840, 113635, 100, 8, 2}, Value: ext}},
	}, d.inter, &d.key.PublicKey, d.interK)
	obj := map[string]any{
		"fmt":      "apple-appattest",
		"attStmt":  map[string]any{"x5c": [][]byte{leaf.Raw, d.inter.Raw}, "receipt": []byte("receipt")},
		"authData": authData,
	}
	raw, err := cbor.Marshal(obj)
	if err != nil {
		d.t.Fatal(err)
	}
	return raw
}

// assertion returns an assertion over binding with counter.
func (d *device) assertion(binding [32]byte, counter uint32) []byte {
	cdh := sha256.Sum256(binding[:])
	authData := authenticatorData(counter, nil, nil, appID)
	nonce := sha256.Sum256(append(append([]byte{}, authData...), cdh[:]...))
	digest := sha256.Sum256(nonce[:])
	sig, err := ecdsa.SignASN1(rand.Reader, d.key, digest[:])
	if err != nil {
		d.t.Fatal(err)
	}
	raw, err := cbor.Marshal(map[string]any{"signature": sig, "authenticatorData": authData})
	if err != nil {
		d.t.Fatal(err)
	}
	return raw
}

func verifier(d *device, store *memory.Store) attest.AppAttest {
	roots := x509.NewCertPool()
	roots.AddCert(d.root)
	return attest.AppAttest{AppID: appID, Roots: roots, AAGUID: attest.AAGUIDProduction, Keys: store, Clock: fixedClock{now}}
}

func TestREQAPI004AppAttestFirstWriteOfTheDayThenAssertions(t *testing.T) {
	d, store, ctx := newDevice(t), memory.New(), context.Background()
	v := verifier(d, store)
	p := domain.Pseudonym{1}
	b1, b2 := [32]byte{1}, [32]byte{2}
	first := domain.Attestation{Platform: domain.PlatformIOS, KeyID: d.keyID, KeyAttestation: d.attestation(b1, nil), Token: d.assertion(b1, 1), Binding: b1}
	if err := v.Verify(ctx, first, p); err != nil {
		t.Fatalf("first write: %v", err)
	}
	second := domain.Attestation{Platform: domain.PlatformIOS, KeyID: d.keyID, Token: d.assertion(b2, 2), Binding: b2}
	if err := v.Verify(ctx, second, p); err != nil {
		t.Fatalf("second write: %v", err)
	}
	if err := v.Verify(ctx, second, p); !errors.Is(err, domain.ErrAttestationInvalid) {
		t.Fatalf("replayed assertion: %v", err)
	}
	other := domain.Attestation{Platform: domain.PlatformIOS, KeyID: d.keyID, Token: d.assertion(b1, 3), Binding: b2}
	if err := v.Verify(ctx, other, p); !errors.Is(err, domain.ErrAttestationInvalid) {
		t.Fatalf("assertion for another request: %v", err)
	}
	if err := v.Verify(ctx, domain.Attestation{Platform: domain.PlatformIOS, KeyID: d.keyID, Token: d.assertion(b2, 9), Binding: b2}, domain.Pseudonym{2}); !errors.Is(err, domain.ErrAttestationInvalid) {
		t.Fatalf("assertion under an unattested pseudonym: %v", err)
	}
}

func TestREQAPI004AppAttestRejectsForgedAttestations(t *testing.T) {
	b := [32]byte{5}
	cases := []struct {
		name  string
		build func(d *device) domain.Attestation
		setup func(v *attest.AppAttest)
		want  error
	}{
		{"nonce for another request", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: d.keyID, KeyAttestation: d.attestation([32]byte{6}, nil), Token: d.assertion(b, 1), Binding: b}
		}, nil, domain.ErrAttestationInvalid},
		{"key id of another key", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: make([]byte, 32), KeyAttestation: d.attestation(b, nil), Token: d.assertion(b, 1), Binding: b}
		}, nil, domain.ErrAttestationInvalid},
		{"nonzero counter", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: d.keyID, KeyAttestation: d.attestation(b, func(ad *[]byte, nonce *[]byte) {
				(*ad)[36] = 1
				cdh := sha256.Sum256(b[:])
				sum := sha256.Sum256(append(append([]byte{}, *ad...), cdh[:]...))
				*nonce = sum[:]
			}), Token: d.assertion(b, 1), Binding: b}
		}, nil, domain.ErrAttestationInvalid},
		{"another app", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: d.keyID, KeyAttestation: d.attestation(b, nil), Token: d.assertion(b, 1), Binding: b}
		}, func(v *attest.AppAttest) { v.AppID = "TEAMID1234.other.app" }, domain.ErrAttestationInvalid},
		{"development environment in production", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: d.keyID, KeyAttestation: d.attestation(b, nil), Token: d.assertion(b, 1), Binding: b}
		}, func(v *attest.AppAttest) { v.AAGUID = attest.AAGUIDDevelopment }, domain.ErrAttestationInvalid},
		{"untrusted root", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: d.keyID, KeyAttestation: d.attestation(b, nil), Token: d.assertion(b, 1), Binding: b}
		}, func(v *attest.AppAttest) { v.Roots = x509.NewCertPool() }, domain.ErrAttestationInvalid},
		{"root not configured", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: d.keyID, KeyAttestation: d.attestation(b, nil), Token: d.assertion(b, 1), Binding: b}
		}, func(v *attest.AppAttest) { v.Roots = nil }, domain.ErrAttestationUnavailable},
		{"garbage", func(d *device) domain.Attestation {
			return domain.Attestation{KeyID: d.keyID, KeyAttestation: []byte{0xff, 0x00}, Token: d.assertion(b, 1), Binding: b}
		}, nil, domain.ErrAttestationInvalid},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			d, store := newDevice(t), memory.New()
			v := verifier(d, store)
			if tc.setup != nil {
				tc.setup(&v)
			}
			a := tc.build(d)
			a.Platform = domain.PlatformIOS
			if err := v.Verify(context.Background(), a, domain.Pseudonym{1}); !errors.Is(err, tc.want) {
				t.Fatalf("err = %v, want %v", err, tc.want)
			}
		})
	}
}
