package kmskeys_test

import (
	"crypto/ed25519"
	"crypto/x509"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"encoding/pem"
	"errors"
	"hash/crc32"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/kmskeys"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

const (
	version = "projects/dm-release/locations/europe-west1/keyRings/dm-distribution/cryptoKeys/targets-1/cryptoKeyVersions/1"
	bearer  = "fake-kms-bearer" //nolint:gosec // a test value the fake KMS accepts, not a credential
)

var castagnoli = crc32.MakeTable(crc32.Castagnoli)

func crc(b []byte) string { return strconv.FormatUint(uint64(crc32.Checksum(b, castagnoli)), 10) }

// fakeKMS answers getPublicKey and asymmetricSign for one key version, as
// the KMS REST API v1 does; tamper edits each sign answer.
func fakeKMS(t *testing.T, s trust.Signer, algorithm string, tamper func(map[string]any)) *httptest.Server {
	t.Helper()
	raw, err := hex.DecodeString(s.PublicKey().Hex())
	if err != nil {
		t.Fatal(err)
	}
	der, err := x509.MarshalPKIXPublicKey(ed25519.PublicKey(raw))
	if err != nil {
		t.Fatal(err)
	}
	pemText := string(pem.EncodeToMemory(&pem.Block{Type: "PUBLIC KEY", Bytes: der}))
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("Authorization") != "Bearer "+bearer {
			http.Error(w, "unauthenticated", http.StatusUnauthorized)
			return
		}
		var answer map[string]any
		switch {
		case r.Method == http.MethodGet && r.URL.Path == "/v1/"+version+"/publicKey":
			answer = map[string]any{"pem": pemText, "algorithm": algorithm, "pemCrc32c": crc([]byte(pemText)), "name": version}
		case r.Method == http.MethodPost && r.URL.Path == "/v1/"+version+":asymmetricSign":
			var req struct{ Data, DataCrc32c string }
			if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
				http.Error(w, "bad request", http.StatusBadRequest)
				return
			}
			data, err := base64.StdEncoding.DecodeString(req.Data)
			if err != nil {
				http.Error(w, "bad request", http.StatusBadRequest)
				return
			}
			sig, err := s.Sign(r.Context(), data)
			if err != nil {
				http.Error(w, "internal", http.StatusInternalServerError)
				return
			}
			answer = map[string]any{
				"signature": base64.StdEncoding.EncodeToString(sig), "signatureCrc32c": crc(sig),
				"verifiedDataCrc32c": req.DataCrc32c == crc(data), "name": version,
			}
			if tamper != nil {
				tamper(answer)
			}
		default:
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(answer) // test server; the client checks what it reads
	}))
	t.Cleanup(server.Close)
	return server
}

func ring(server *httptest.Server, vars map[string]string) kmskeys.Ring {
	return kmskeys.Ring{
		Prefix:   "DM_KMS_",
		Lookup:   func(k string) (string, bool) { v, ok := vars[k]; return v, ok },
		Endpoint: server.URL,
		Client:   server.Client(),
	}
}

var configured = map[string]string{"DM_KMS_TARGETS_KEY_1": version, "DM_KMS_ACCESS_TOKEN": bearer}

func TestKeyRingContract_REQ_TEST_004(t *testing.T) {
	ks := testsupport.NewKeySet(t)
	server := fakeKMS(t, ks.Signers["targets-1"], kmskeys.Algorithm, nil)
	testsupport.KeyRingContract(t, ks, func(*testing.T) ports.KeyRing { return ring(server, configured) })
}

func TestKMSSignaturesAreEd25519OverTheMessage_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	server := fakeKMS(t, ks.Signers["targets-1"], kmskeys.Algorithm, nil)
	s, err := ring(server, configured).Signer(t.Context(), "targets-1")
	if err != nil {
		t.Fatal(err)
	}

	sig, err := s.Sign(t.Context(), []byte(`{"_type":"targets"}`))

	if err != nil || !ks.Signers["targets-1"].PublicKey().Verify([]byte(`{"_type":"targets"}`), sig) {
		t.Fatalf("signature does not verify: %v", err)
	}
}

func TestKMSAnswersThatDoNotCheckOutAreRefused(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	signer := ks.Signers["targets-1"]
	tests := []struct {
		name      string
		algorithm string
		tamper    func(map[string]any)
	}{
		{"an unverified data checksum", kmskeys.Algorithm, func(a map[string]any) { a["verifiedDataCrc32c"] = false }},
		{"a wrong signature checksum", kmskeys.Algorithm, func(a map[string]any) { a["signatureCrc32c"] = "1" }},
		{"another key version", kmskeys.Algorithm, func(a map[string]any) { a["name"] = strings.Replace(version, "/1", "/2", 1) }},
	}
	for _, tc := range tests {
		s, err := ring(fakeKMS(t, signer, tc.algorithm, tc.tamper), configured).Signer(t.Context(), "targets-1")
		if err != nil {
			t.Fatalf("%s: %v", tc.name, err)
		}
		if _, err := s.Sign(t.Context(), []byte("m")); !errors.Is(err, kmskeys.ErrKMS) {
			t.Errorf("%s: err = %v, want ErrKMS", tc.name, err)
		}
	}
	if _, err := ring(fakeKMS(t, signer, "EC_SIGN_P256_SHA256", nil), configured).Signer(t.Context(), "targets-1"); !errors.Is(err, kmskeys.ErrKMS) {
		t.Errorf("a P-256 key: err = %v, want ErrKMS", err)
	}
}

func TestKMSConfigurationIsCheckedBeforeAnyCall_REQ_SEC_030(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	server := fakeKMS(t, ks.Signers["targets-1"], kmskeys.Algorithm, nil)
	tests := []struct {
		name string
		key  string
		vars map[string]string
		want error
	}{
		{"no version for the key", "targets-2", configured, ports.ErrNotFound},
		{"no access token", "targets-1", map[string]string{"DM_KMS_TARGETS_KEY_1": version}, kmskeys.ErrConfig},
		{"not a version resource", "targets-1", map[string]string{"DM_KMS_TARGETS_KEY_1": "projects/x/../y", "DM_KMS_ACCESS_TOKEN": bearer}, kmskeys.ErrConfig},
		{"a bad key name", "targets", configured, kmskeys.ErrConfig},
		{"a wrong token", "targets-1", map[string]string{"DM_KMS_TARGETS_KEY_1": version, "DM_KMS_ACCESS_TOKEN": "other"}, kmskeys.ErrKMS},
	}
	for _, tc := range tests {
		if _, err := ring(server, tc.vars).Signer(t.Context(), tc.key); !errors.Is(err, tc.want) {
			t.Errorf("%s: err = %v, want %v", tc.name, err, tc.want)
		}
	}
}
