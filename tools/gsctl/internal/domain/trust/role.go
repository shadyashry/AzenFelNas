package trust

import (
	"fmt"
	"time"
)

// RoleName is one of the four TUF-lite roles (REQ-DIST-001).
type RoleName string

// The four roles.
const (
	RoleRoot      RoleName = "root"
	RoleTargets   RoleName = "targets"
	RoleSnapshot  RoleName = "snapshot"
	RoleTimestamp RoleName = "timestamp"
)

// Roles lists the roles in signing order: root first, timestamp last.
func Roles() []RoleName {
	return []RoleName{RoleRoot, RoleTargets, RoleSnapshot, RoleTimestamp}
}

// ParseRoleName returns the role named s.
func ParseRoleName(s string) (RoleName, error) {
	for _, r := range Roles() {
		if string(r) == s {
			return r, nil
		}
	}
	return "", fmt.Errorf("unknown role %q (want root, targets, snapshot or timestamp)", s)
}

// FileName is the role's metadata file name, e.g. "targets.json".
func (r RoleName) FileName() string { return string(r) + ".json" }

// DefaultLifetime is how long a freshly signed role stays valid unless the
// signer asks otherwise (§15 D59): root 365 d, targets 90 d, snapshot 30 d,
// timestamp 7 d, the §9.1 maximum.
func (r RoleName) DefaultLifetime() time.Duration {
	const day = 24 * time.Hour
	switch r {
	case RoleRoot:
		return 365 * day
	case RoleTargets:
		return 90 * day
	case RoleSnapshot:
		return 30 * day
	case RoleTimestamp:
		return MaxTimestampLifetime
	default:
		return 0
	}
}

// MaxTimestampLifetime is the longest a timestamp may stay valid (§9.1).
const MaxTimestampLifetime = 7 * 24 * time.Hour

// expiresLayout is the schema's UTC, second-precision form.
const expiresLayout = "2006-01-02T15:04:05Z"

// FormatExpires writes t in the schema's form, truncated to the second.
func FormatExpires(t time.Time) string {
	return t.UTC().Truncate(time.Second).Format(expiresLayout)
}

// ParseExpires reads the schema's expiry form.
func ParseExpires(s string) (time.Time, error) {
	t, err := time.Parse(expiresLayout, s)
	if err != nil {
		return time.Time{}, fmt.Errorf("%w: expires %q: %w", ErrMalformed, s, err)
	}
	return t, nil
}
