package keyfiles_test

import (
	"slices"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/keyfiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
)

const devKeys = "../../../keys/dev"

// The committed dev key set builds a root with the Appendix C thresholds,
// and its root keys are exactly the trust anchor an app embeds
// (REQ-DIST-001, §15 D17, D62).
func TestDevKeySetMatchesTheTrustAnchor_REQ_DIST_001(t *testing.T) {
	t.Parallel()
	config, err := keyfiles.KeyConfig{Dir: devKeys}.LoadKeyConfig(t.Context())
	if err != nil {
		t.Fatal(err)
	}
	anchor, err := keyfiles.TrustAnchor{File: devKeys + "/root-keys.json"}.LoadTrustAnchor(t.Context())
	if err != nil {
		t.Fatal(err)
	}
	if _, err := trust.NewRoot(1, time.Now(), config); err != nil {
		t.Fatalf("NewRoot from the dev key set: %v", err)
	}
	var configured, anchored []string
	for _, k := range config.Roles[trust.RoleRoot].Keys {
		configured = append(configured, k.Key.ID())
	}
	for _, k := range anchor.Keys {
		anchored = append(anchored, k.ID())
	}
	slices.Sort(configured)
	slices.Sort(anchored)
	if !slices.Equal(configured, anchored) || anchor.Threshold != config.Roles[trust.RoleRoot].Threshold {
		t.Fatalf("roles.json root keys %v (threshold %d) differ from root-keys.json %v (threshold %d)",
			configured, config.Roles[trust.RoleRoot].Threshold, anchored, anchor.Threshold)
	}
}
