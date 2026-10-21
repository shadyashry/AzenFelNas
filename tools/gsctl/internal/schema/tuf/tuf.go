// Package tuf holds the hand-written Go wire model of tuf_metadata.v1
// (Appendix C, ADR-009, ADR-023, §15 D24). Signing and verification over the
// JCS canonical form of Signed live in internal/domain/trust (S09).
package tuf

import (
	"errors"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"
)

// ErrUnknownRole is returned for a "signed" document of an unknown type.
var ErrUnknownRole = errors.New("tuf: unknown role type")

// ErrEmptySigned is returned when encoding Signed without a variant.
var ErrEmptySigned = errors.New("tuf: signed has no variant")

// Metadata is a signed metadata envelope.
type Metadata struct {
	Signed     Signed      `json:"signed"`
	Signatures []Signature `json:"signatures"`
}

// UnmarshalJSON decodes an envelope, rejecting unknown keys at every level.
func (m *Metadata) UnmarshalJSON(data []byte) error {
	type plain Metadata
	var v plain
	if err := jsonx.DecodeStrict(data, &v); err != nil {
		return err
	}
	*m = Metadata(v)
	return nil
}

// Signature is one Ed25519 signature over JCS(signed) (REQ-DIST-004).
type Signature struct {
	KeyID string `json:"keyId"`
	Sig   string `json:"sig"`
}

// Signed is the role document of an envelope, encoded with its "type".
// Variant is never nil after decoding.
type Signed struct {
	Variant SignedVariant
}

// SignedVariant is implemented by the four roles only.
type SignedVariant interface {
	roleType() string
}

// Root holds the trusted keys and role thresholds (REQ-DIST-001).
type Root struct {
	Version int            `json:"version"`
	Expires string         `json:"expires"`
	Keys    map[string]Key `json:"keys"`
	Roles   Roles          `json:"roles"`
}

// Targets lists the content-addressed packages (REQ-DIST-003).
type Targets struct {
	Sequence int               `json:"sequence"`
	Expires  string            `json:"expires"`
	Targets  map[string]Target `json:"targets"`
}

// Snapshot pins targets.json.
type Snapshot struct {
	Sequence int          `json:"sequence"`
	Expires  string       `json:"expires"`
	Meta     SnapshotMeta `json:"meta"`
}

// Timestamp pins snapshot.json and expires within 7 days.
type Timestamp struct {
	Sequence int           `json:"sequence"`
	Expires  string        `json:"expires"`
	Meta     TimestampMeta `json:"meta"`
}

func (Root) roleType() string      { return "root" }
func (Targets) roleType() string   { return "targets" }
func (Snapshot) roleType() string  { return "snapshot" }
func (Timestamp) roleType() string { return "timestamp" }

// MarshalJSON encodes the role document with its "type".
func (s Signed) MarshalJSON() ([]byte, error) {
	if s.Variant == nil {
		return nil, ErrEmptySigned
	}
	return jsonx.WithTag("type", s.Variant.roleType(), s.Variant)
}

// UnmarshalJSON decodes the role named by "type", rejecting unknown keys.
func (s *Signed) UnmarshalJSON(data []byte) error {
	tag, rest, err := jsonx.SplitTag(data, "type")
	if err != nil {
		return err
	}
	switch tag {
	case "root":
		return decodeSigned[Root](rest, s)
	case "targets":
		return decodeSigned[Targets](rest, s)
	case "snapshot":
		return decodeSigned[Snapshot](rest, s)
	case "timestamp":
		return decodeSigned[Timestamp](rest, s)
	default:
		return fmt.Errorf("%w %q", ErrUnknownRole, tag)
	}
}

func decodeSigned[V SignedVariant](data []byte, s *Signed) error {
	var v V
	if err := jsonx.DecodeStrict(data, &v); err != nil {
		return err
	}
	s.Variant = v
	return nil
}

// Key is a public key.
type Key struct {
	Scheme KeyScheme `json:"scheme"`
	Public string    `json:"public"`
}

// Role lists the keys allowed to sign and how many must.
type Role struct {
	KeyIDs    []string `json:"keyIds"`
	Threshold int      `json:"threshold"`
}

// Roles are the four TUF-lite roles.
type Roles struct {
	Root      Role `json:"root"`
	Targets   Role `json:"targets"`
	Snapshot  Role `json:"snapshot"`
	Timestamp Role `json:"timestamp"`
}

// Target is one content-addressed package.
type Target struct {
	Length int64        `json:"length"`
	SHA256 string       `json:"sha256"`
	Custom TargetCustom `json:"custom"`
}

// TargetCustom is the package metadata of a target (§9.1).
type TargetCustom struct {
	SchemaVersion int           `json:"schemaVersion"`
	PayloadFormat PayloadFormat `json:"payloadFormat"`
	Compat        Compat        `json:"compat"`
	EffectiveFrom string        `json:"effectiveFrom"`
	Priority      Priority      `json:"priority"`
	ChangeNote    ChangeNote    `json:"changeNote"`
	RollbackOf    *string       `json:"rollbackOf,omitempty"`
	Attribution   *string       `json:"attribution,omitempty"`
}

// Compat is the compatibility gate checked before activation (REQ-PKG-006).
type Compat struct {
	MinApp          string `json:"minApp"`
	MinEngineSchema int    `json:"minEngineSchema"`
}

// ChangeNote is shown when displayed times change.
type ChangeNote struct {
	Ar string `json:"ar"`
	En string `json:"en"`
}

// MetaRef references another metadata file.
type MetaRef struct {
	Version int    `json:"version"`
	SHA256  string `json:"sha256"`
}

// SnapshotMeta is the meta object of the snapshot role.
type SnapshotMeta struct {
	TargetsJSON MetaRef `json:"targets.json"`
}

// TimestampMeta is the meta object of the timestamp role.
type TimestampMeta struct {
	SnapshotJSON MetaRef `json:"snapshot.json"`
}

// KeyScheme is the signature scheme of a key.
type KeyScheme string

// KeySchemeEd25519 is the only scheme (Appendix C).
const KeySchemeEd25519 KeyScheme = "ed25519"

// UnmarshalText accepts only ed25519.
func (k *KeyScheme) UnmarshalText(b []byte) (err error) {
	*k, err = jsonx.ParseEnum(b, KeySchemeEd25519)
	return err
}

// PayloadFormat is the payload format of a package (§9.5).
type PayloadFormat string

// PayloadFormat values.
const (
	PayloadJSON   PayloadFormat = "json"
	PayloadBin    PayloadFormat = "bin"
	PayloadSQLite PayloadFormat = "sqlite"
)

// UnmarshalText accepts only the PayloadFormat values.
func (p *PayloadFormat) UnmarshalText(b []byte) (err error) {
	*p, err = jsonx.ParseEnum(b, PayloadJSON, PayloadBin, PayloadSQLite)
	return err
}

// Priority is the download priority (§7.4).
type Priority string

// Priority values.
const (
	PriorityNormal Priority = "normal"
	PriorityUrgent Priority = "urgent"
)

// UnmarshalText accepts only the Priority values.
func (p *Priority) UnmarshalText(b []byte) (err error) {
	*p, err = jsonx.ParseEnum(b, PriorityNormal, PriorityUrgent)
	return err
}
