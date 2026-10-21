package profile

import "github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"

// Status is the profile lifecycle status.
type Status string

// Status values.
const (
	StatusDraftUnverified Status = "DRAFT_UNVERIFIED"
	StatusCandidate       Status = "CANDIDATE"
	StatusApproved        Status = "APPROVED"
	StatusRetired         Status = "RETIRED"
)

// UnmarshalText accepts only the Status values.
func (s *Status) UnmarshalText(b []byte) (err error) {
	*s, err = jsonx.ParseEnum(b, StatusDraftUnverified, StatusCandidate, StatusApproved, StatusRetired)
	return err
}

// AuthorityType is the kind of authority behind a profile (ADR-007).
type AuthorityType string

// AuthorityType values.
const (
	AuthorityGovernment          AuthorityType = "GOVERNMENT"
	AuthorityRecognizedBody      AuthorityType = "RECOGNIZED_BODY"
	AuthorityCommunityConvention AuthorityType = "COMMUNITY_CONVENTION"
	AuthorityEngineDefault       AuthorityType = "ENGINE_DEFAULT"
)

// UnmarshalText accepts only the AuthorityType values.
func (a *AuthorityType) UnmarshalText(b []byte) (err error) {
	*a, err = jsonx.ParseEnum(b, AuthorityGovernment, AuthorityRecognizedBody, AuthorityCommunityConvention, AuthorityEngineDefault)
	return err
}

// ReferenceMode says where the engine calculates (ADR-006).
type ReferenceMode string

// ReferenceMode values.
const (
	ReferenceExactCoordinate         ReferenceMode = "EXACT_COORDINATE"
	ReferenceAuthorityReferencePoint ReferenceMode = "AUTHORITY_REFERENCE_POINT"
)

// UnmarshalText accepts only the ReferenceMode values.
func (r *ReferenceMode) UnmarshalText(b []byte) (err error) {
	*r, err = jsonx.ParseEnum(b, ReferenceExactCoordinate, ReferenceAuthorityReferencePoint)
	return err
}

// ElevationPolicy is the horizon elevation policy (ADR-003).
type ElevationPolicy string

// ElevationPolicy values.
const (
	ElevationNone              ElevationPolicy = "NONE"
	ElevationAboveLocalTerrain ElevationPolicy = "ABOVE_LOCAL_TERRAIN"
	ElevationAuthorityTable    ElevationPolicy = "AUTHORITY_TABLE"
)

// UnmarshalText accepts only the ElevationPolicy values.
func (e *ElevationPolicy) UnmarshalText(b []byte) (err error) {
	*e, err = jsonx.ParseEnum(b, ElevationNone, ElevationAboveLocalTerrain, ElevationAuthorityTable)
	return err
}

// RoundingMode is a per-event rounding mode (ADR-005).
type RoundingMode string

// RoundingMode values.
const (
	RoundingCeil    RoundingMode = "ceil"
	RoundingFloor   RoundingMode = "floor"
	RoundingNearest RoundingMode = "nearest"
)

// UnmarshalText accepts only the RoundingMode values.
func (r *RoundingMode) UnmarshalText(b []byte) (err error) {
	*r, err = jsonx.ParseEnum(b, RoundingCeil, RoundingFloor, RoundingNearest)
	return err
}

// IntervalBase is the base event of an interval rule.
type IntervalBase string

// IntervalBase values.
const (
	BaseMaghrib IntervalBase = "maghrib"
	BaseFajr    IntervalBase = "fajr"
)

// UnmarshalText accepts only the IntervalBase values.
func (i *IntervalBase) UnmarshalText(b []byte) (err error) {
	*i, err = jsonx.ParseEnum(b, BaseMaghrib, BaseFajr)
	return err
}
