// Package profile holds the hand-written Go wire model of prayer_profile.v1
// (Appendix A, ADR-007, ADR-023, §15 D24). Members the schema allows to be
// null are always written, as null when unset; profile values are data only
// (§0.2 rule 1). Validation beyond shape arrives with gsctl validate (S09).
package profile

import "github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"

// PrayerProfile is one compiled prayer profile.
type PrayerProfile struct {
	ProfileID       string                  `json:"profileId"`
	SchemaVersion   int                     `json:"schemaVersion"`
	Version         string                  `json:"version"`
	Status          Status                  `json:"status"`
	EffectiveFrom   string                  `json:"effectiveFrom"`
	EffectiveTo     *string                 `json:"effectiveTo"`
	Scope           Scope                   `json:"scope"`
	Authority       Authority               `json:"authority"`
	ReferenceMode   ReferenceMode           `json:"referenceMode"`
	ReferencePoints []ReferencePoint        `json:"referencePoints"`
	Rules           Rules                   `json:"rules"`
	Horizon         HorizonSettings         `json:"horizon"`
	HighLatitude    HighLatitude            `json:"highLatitude"`
	Rounding        map[string]RoundingMode `json:"rounding"`
	Adjustments     Adjustments             `json:"adjustments"`
	Evidence        Evidence                `json:"evidence"`
	Approvals       Approvals               `json:"approvals"`
	Compatibility   Compatibility           `json:"compatibility"`
}

// UnmarshalJSON decodes a profile, rejecting unknown keys at every level.
func (p *PrayerProfile) UnmarshalJSON(data []byte) error {
	type plain PrayerProfile
	var v plain
	if err := jsonx.DecodeStrict(data, &v); err != nil {
		return err
	}
	*p = PrayerProfile(v)
	return nil
}

// Scope is the geographic scope (ADR-007).
type Scope struct {
	Countries   []string `json:"countries"`
	AdminAreas  []string `json:"adminAreas"`
	PolygonsRef *string  `json:"polygonsRef"`
}

// Authority names the authority behind a profile.
type Authority struct {
	Name string        `json:"name"`
	Type AuthorityType `json:"type"`
}

// ReferencePoint is a point used in AUTHORITY_REFERENCE_POINT mode.
type ReferencePoint struct {
	Area string  `json:"area"`
	Lat  float64 `json:"lat"`
	Lon  float64 `json:"lon"`
}

// Rules holds the rule of each event; Imsak is nil when the profile has none.
type Rules struct {
	Imsak   *Rule `json:"imsak"`
	Fajr    Rule  `json:"fajr"`
	Sunrise Rule  `json:"sunrise"`
	Dhuhr   Rule  `json:"dhuhr"`
	Asr     Rule  `json:"asr"`
	Maghrib Rule  `json:"maghrib"`
	Isha    Rule  `json:"isha"`
}

// HorizonSettings holds the horizon elevation policy.
type HorizonSettings struct {
	ElevationPolicy ElevationPolicy `json:"elevationPolicy"`
}

// HighLatitude is the ordered fallback chain.
type HighLatitude struct {
	Chain []HighLatitudeMethod `json:"chain"`
}

// Adjustments holds additive offsets and Ramadan rule replacements.
type Adjustments struct {
	PerEventMinutes map[string]int  `json:"perEventMinutes"`
	MaxAbsMinutes   int             `json:"maxAbsMinutes"`
	Ramadan         map[string]Rule `json:"ramadan"`
}

// EvidenceSource is one evidence source.
type EvidenceSource struct {
	Title       string `json:"title"`
	URL         string `json:"url"`
	RetrievedOn string `json:"retrievedOn"`
	SHA256      string `json:"sha256"`
}

// Evidence is the evidence behind a profile (ADR-008).
type Evidence struct {
	Sources           []EvidenceSource `json:"sources"`
	BenchmarkSet      string           `json:"benchmarkSet"`
	HoldoutReport     *string          `json:"holdoutReport"`
	BenchmarkReportID *string          `json:"benchmarkReportId"`
}

// ReligiousApproval is the signed religious approval (ADR-008).
type ReligiousApproval struct {
	Reviewer      string   `json:"reviewer"`
	Qualification string   `json:"qualification"`
	Date          string   `json:"date"`
	Scope         []string `json:"scope"`
}

// AccuracyApproval is the accuracy approval.
type AccuracyApproval struct {
	Reviewer string `json:"reviewer"`
	Date     string `json:"date"`
}

// Approvals are both always written; nil when missing.
type Approvals struct {
	Religious *ReligiousApproval `json:"religious"`
	Accuracy  *AccuracyApproval  `json:"accuracy"`
}

// Compatibility is the minimum engine schema and app version.
type Compatibility struct {
	MinEngineSchema int    `json:"minEngineSchema"`
	MinAppVersion   string `json:"minAppVersion"`
}
