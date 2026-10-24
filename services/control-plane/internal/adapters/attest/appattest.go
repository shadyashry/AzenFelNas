package attest

import (
	"bytes"
	"context"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/sha256"
	"crypto/x509"
	"encoding/asn1"
	"encoding/binary"
	"errors"
	"fmt"

	"github.com/fxamacker/cbor/v2"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// App Attest authenticator data AAGUIDs.
var (
	AAGUIDProduction  = []byte("appattest\x00\x00\x00\x00\x00\x00\x00")
	AAGUIDDevelopment = []byte("appattestdevelop")
)

// nonceExtension is the OID of the App Attest nonce in the credential certificate.
var nonceExtension = asn1.ObjectIdentifier{1, 2, 840, 113635, 100, 8, 2}

// AppAttest verifies App Attest keys and assertions (§15 D86). The client
// generates one key per UTC day; the first write of the day carries the
// key's attestation object and every write carries an assertion. clientData
// is the request binding. Verified public keys are kept under the daily
// pseudonym for at most 24 h (REQ-PRIV-007).
type AppAttest struct {
	// AppID is "<team id>.<bundle id>".
	AppID string
	// Roots holds the Apple App Attestation Root CA, supplied by the owner (§15 D86).
	Roots *x509.CertPool
	// AAGUID is AAGUIDProduction or AAGUIDDevelopment.
	AAGUID []byte
	Keys   ports.AttestedKeyStore
	Clock  ports.Clock
}

type attestationObject struct {
	Fmt     string `cbor:"fmt"`
	AttStmt struct {
		X5C     [][]byte `cbor:"x5c"`
		Receipt []byte   `cbor:"receipt"`
	} `cbor:"attStmt"`
	AuthData []byte `cbor:"authData"`
}

type assertionObject struct {
	Signature         []byte `cbor:"signature"`
	AuthenticatorData []byte `cbor:"authenticatorData"`
}

// Verify implements ports.AttestationVerifier.
func (v AppAttest) Verify(ctx context.Context, a domain.Attestation, p domain.Pseudonym) error {
	clientDataHash := sha256.Sum256(a.Binding[:])
	if len(a.KeyAttestation) > 0 {
		pub, err := v.verifyAttestation(a.KeyAttestation, a.KeyID, clientDataHash[:])
		if err != nil {
			return err
		}
		if err := v.Keys.PutAttestedKey(ctx, p, ports.AttestedKey{PublicKey: pub, Counter: 0}, v.Clock.Now()); err != nil {
			return fmt.Errorf("%w: store key: %w", domain.ErrAttestationUnavailable, err)
		}
	}
	key, err := v.Keys.AttestedKey(ctx, p)
	if errors.Is(err, domain.ErrNotFound) {
		return fmt.Errorf("%w: app attest: key not attested today", domain.ErrAttestationInvalid)
	}
	if err != nil {
		return fmt.Errorf("%w: load key: %w", domain.ErrAttestationUnavailable, err)
	}
	counter, err := v.verifyAssertion(a.Token, key.PublicKey, clientDataHash[:])
	if err != nil {
		return err
	}
	advanced, err := v.Keys.AdvanceCounter(ctx, p, counter)
	if err != nil {
		return fmt.Errorf("%w: counter: %w", domain.ErrAttestationUnavailable, err)
	}
	if !advanced {
		return fmt.Errorf("%w: app attest: replayed assertion", domain.ErrAttestationInvalid)
	}
	return nil
}

func invalidAppAttest(why string) error {
	return fmt.Errorf("%w: app attest: %s", domain.ErrAttestationInvalid, why)
}

// verifyAttestation follows Apple's "Validating apps that connect to your
// server" steps 1-9 and returns the credential's PKIX public key.
func (v AppAttest) verifyAttestation(raw []byte, keyID domain.AttestationKeyID, clientDataHash []byte) ([]byte, error) {
	if v.Roots == nil {
		return nil, fmt.Errorf("%w: app attest root not configured", domain.ErrAttestationUnavailable)
	}
	var obj attestationObject
	if err := cbor.Unmarshal(raw, &obj); err != nil {
		return nil, invalidAppAttest("attestation object")
	}
	if obj.Fmt != "apple-appattest" || len(obj.AttStmt.X5C) < 2 {
		return nil, invalidAppAttest("format")
	}
	certs := make([]*x509.Certificate, len(obj.AttStmt.X5C))
	for i, der := range obj.AttStmt.X5C {
		c, err := x509.ParseCertificate(der)
		if err != nil {
			return nil, invalidAppAttest("certificate")
		}
		certs[i] = c
	}
	intermediates := x509.NewCertPool()
	for _, c := range certs[1:] {
		intermediates.AddCert(c)
	}
	// Step 1: the credential certificate chains to Apple's root.
	if _, err := certs[0].Verify(x509.VerifyOptions{
		Roots: v.Roots, Intermediates: intermediates, CurrentTime: v.Clock.Now(),
		KeyUsages: []x509.ExtKeyUsage{x509.ExtKeyUsageAny},
	}); err != nil {
		return nil, invalidAppAttest("certificate chain")
	}
	// Steps 2-4: the certificate's nonce is sha256(authData || clientDataHash).
	nonce := sha256.Sum256(append(bytes.Clone(obj.AuthData), clientDataHash...))
	if !bytes.Equal(certificateNonce(certs[0]), nonce[:]) {
		return nil, invalidAppAttest("nonce")
	}
	// Step 5: the key id is sha256 of the uncompressed public key point.
	pub, ok := certs[0].PublicKey.(*ecdsa.PublicKey)
	if !ok || pub.Curve != elliptic.P256() {
		return nil, invalidAppAttest("key type")
	}
	point, err := pub.Bytes()
	if err != nil {
		return nil, invalidAppAttest("key encoding")
	}
	if sum := sha256.Sum256(point); !bytes.Equal(sum[:], keyID) {
		return nil, invalidAppAttest("key id")
	}
	// Steps 6-9: rpIdHash, counter 0, AAGUID and credential id.
	ad, err := parseAuthData(obj.AuthData, true)
	if err != nil {
		return nil, err
	}
	appIDHash := sha256.Sum256([]byte(v.AppID))
	switch {
	case !bytes.Equal(ad.rpIDHash, appIDHash[:]):
		return nil, invalidAppAttest("app id")
	case ad.counter != 0:
		return nil, invalidAppAttest("counter")
	case !bytes.Equal(ad.aaguid, v.AAGUID):
		return nil, invalidAppAttest("environment")
	case !bytes.Equal(ad.credentialID, keyID):
		return nil, invalidAppAttest("credential id")
	}
	der, err := x509.MarshalPKIXPublicKey(pub)
	if err != nil {
		return nil, invalidAppAttest("key encoding")
	}
	return der, nil
}

// verifyAssertion checks the signature over sha256(authenticatorData ||
// clientDataHash) and the app id, and returns the assertion's counter.
func (v AppAttest) verifyAssertion(raw, pkix, clientDataHash []byte) (uint32, error) {
	var obj assertionObject
	if err := cbor.Unmarshal(raw, &obj); err != nil {
		return 0, invalidAppAttest("assertion object")
	}
	key, err := x509.ParsePKIXPublicKey(pkix)
	if err != nil {
		return 0, fmt.Errorf("%w: stored key: %w", domain.ErrAttestationUnavailable, err)
	}
	pub, ok := key.(*ecdsa.PublicKey)
	if !ok {
		return 0, fmt.Errorf("%w: stored key type", domain.ErrAttestationUnavailable)
	}
	nonce := sha256.Sum256(append(bytes.Clone(obj.AuthenticatorData), clientDataHash...))
	digest := sha256.Sum256(nonce[:])
	if !ecdsa.VerifyASN1(pub, digest[:], obj.Signature) {
		return 0, invalidAppAttest("signature")
	}
	ad, err := parseAuthData(obj.AuthenticatorData, false)
	if err != nil {
		return 0, err
	}
	if appIDHash := sha256.Sum256([]byte(v.AppID)); !bytes.Equal(ad.rpIDHash, appIDHash[:]) {
		return 0, invalidAppAttest("app id")
	}
	return ad.counter, nil
}

type authData struct {
	rpIDHash     []byte
	counter      uint32
	aaguid       []byte
	credentialID []byte
}

// parseAuthData reads WebAuthn authenticator data: rpIdHash(32) flags(1)
// counter(4) and, when attested, aaguid(16) credIdLen(2) credId.
func parseAuthData(b []byte, attested bool) (authData, error) {
	if len(b) < 37 {
		return authData{}, invalidAppAttest("authenticator data")
	}
	ad := authData{rpIDHash: b[:32], counter: binary.BigEndian.Uint32(b[33:37])}
	if !attested {
		return ad, nil
	}
	if len(b) < 55 {
		return authData{}, invalidAppAttest("authenticator data")
	}
	ad.aaguid = b[37:53]
	n := int(binary.BigEndian.Uint16(b[53:55]))
	if len(b) < 55+n {
		return authData{}, invalidAppAttest("credential id")
	}
	ad.credentialID = b[55 : 55+n]
	return ad, nil
}

// certificateNonce extracts the nonce: SEQUENCE { [1] EXPLICIT OCTET STRING }.
func certificateNonce(c *x509.Certificate) []byte {
	for _, ext := range c.Extensions {
		if !ext.Id.Equal(nonceExtension) {
			continue
		}
		var seq struct {
			Nonce []byte `asn1:"explicit,tag:1"`
		}
		if _, err := asn1.Unmarshal(ext.Value, &seq); err != nil {
			return nil
		}
		return seq.Nonce
	}
	return nil
}
