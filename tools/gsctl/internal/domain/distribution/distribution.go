// Package distribution holds the rules of the static distribution plane
// (§9.1, ADR-009): object keys in the bucket, their cache policy
// (REQ-DIST-005), and which metadata a publish may replace. Pure; the
// bucket itself is a port (a local directory today, R2 in S25, §15 D65).
package distribution

import (
	"bytes"
	"fmt"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
)

// Cache-Control values of §9.1 (REQ-DIST-005).
const (
	CachePackage   = "public, max-age=31536000, immutable"
	CacheTimestamp = "public, max-age=300"
	CacheMetadata  = "public, max-age=3600"
)

// MetadataKey is "{channel}/metadata/{role}.json".
func MetadataKey(channel string, role trust.RoleName) string {
	return channel + "/metadata/" + role.FileName()
}

// PackageKey is "{channel}/packages/{type}/{version}/{sha256}.dmpkg" for
// the target "<type>/<version>".
func PackageKey(channel, target, sha256 string) (string, error) {
	typ, version, ok := strings.Cut(target, "/")
	if !ok || typ == "" || version == "" || strings.Contains(version, "/") {
		return "", fmt.Errorf("%w: target name %q", trust.ErrMalformed, target)
	}
	return channel + "/packages/" + typ + "/" + version + "/" + sha256 + ".dmpkg", nil
}

// CacheControl is the §9.1 policy of a metadata role.
func CacheControl(role trust.RoleName) string {
	if role == trust.RoleTimestamp {
		return CacheTimestamp
	}
	return CacheMetadata
}

// PublishOrder is the order roles are uploaded in, after every package:
// root, then targets, snapshot and timestamp, so that a client following
// the newest timestamp never reaches a file that is not there yet.
func PublishOrder() []trust.RoleName {
	return []trust.RoleName{trust.RoleRoot, trust.RoleTargets, trust.RoleSnapshot, trust.RoleTimestamp}
}

// PlanMetadata returns, in PublishOrder, the roles whose local file differs
// from the published one (nil when a role was never published). A changed
// role must carry a sequence (root: version) strictly greater than the
// published one; an equal or lower one is trust.ErrSequenceRegression
// (REQ-DIST-002). Identical files are left alone, so refreshing only the
// timestamp re-uploads only the timestamp.
func PlanMetadata(local, published map[trust.RoleName][]byte) ([]trust.RoleName, error) {
	var changed []trust.RoleName
	for _, role := range PublishOrder() {
		mine, ok := local[role]
		if !ok {
			return nil, fmt.Errorf("%w: %s is not signed", trust.ErrMalformed, role.FileName())
		}
		theirs, wasPublished := published[role]
		if wasPublished && bytes.Equal(mine, theirs) {
			continue
		}
		if wasPublished {
			if err := checkNewer(role, mine, theirs); err != nil {
				return nil, err
			}
		}
		changed = append(changed, role)
	}
	return changed, nil
}

func checkNewer(role trust.RoleName, mine, theirs []byte) error {
	m, err := trust.ParseEnvelope(mine)
	if err != nil {
		return fmt.Errorf("%s: %w", role.FileName(), err)
	}
	t, err := trust.ParseEnvelope(theirs)
	if err != nil {
		return fmt.Errorf("published %s: %w", role.FileName(), err)
	}
	if m.Sequence() <= t.Sequence() {
		return fmt.Errorf("%w: %s %d is not after the published %d", trust.ErrSequenceRegression, role.FileName(), m.Sequence(), t.Sequence())
	}
	return nil
}
