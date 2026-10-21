// Package telemetry holds the hand-written Go wire model of
// telemetry_aggregate.v1 (Appendix L, ADR-023, §15 D24): daily counters with
// no ids, no coordinates and day granularity (REQ-PRIV-001). Decoding rejects
// unknown keys (REQ-API-005); full schema validation joins the API in S26.
package telemetry

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
)

// ErrUnknownEnum is returned when a string is not one of an enum's values.
var ErrUnknownEnum = errors.New("telemetry: unknown enum value")

// ErrTrailingData is returned when the JSON value is followed by more data.
var ErrTrailingData = errors.New("telemetry: trailing data after JSON value")

// Aggregate is one day's opt-in counters from one device.
type Aggregate struct {
	SchemaVersion int      `json:"schemaVersion"`
	Day           string   `json:"day"`
	AppVersion    string   `json:"appVersion"`
	Platform      Platform `json:"platform"`
	OsMajor       int      `json:"osMajor"`
	CountryCode   *string  `json:"countryCode,omitempty"`
	Counters      Counters `json:"counters"`
}

// UnmarshalJSON decodes an aggregate, rejecting unknown keys at every level.
func (a *Aggregate) UnmarshalJSON(data []byte) error {
	type plain Aggregate
	var v plain
	dec := json.NewDecoder(bytes.NewReader(data))
	dec.DisallowUnknownFields()
	if err := dec.Decode(&v); err != nil {
		return fmt.Errorf("decode telemetry aggregate: %w", err)
	}
	if dec.More() {
		return ErrTrailingData
	}
	*a = Aggregate(v)
	return nil
}

// Counters are the daily counters.
type Counters struct {
	PackageActivations map[PackageType]int `json:"packageActivations"`
	HealthState        map[HealthState]int `json:"healthState"`
	TestResults        TestResults         `json:"testResults"`
	SyncOutcome        SyncOutcome         `json:"syncOutcome"`
}

// TestResults counts Athan Test outcomes.
type TestResults struct {
	Heard    int `json:"heard"`
	NotHeard int `json:"notHeard"`
	Unknown  int `json:"unknown"`
}

// SyncOutcome counts package sync outcomes.
type SyncOutcome struct {
	OK   int `json:"ok"`
	Warn int `json:"warn"`
	Fail int `json:"fail"`
}

// Platform is the device platform.
type Platform string

// Platform values.
const (
	PlatformAndroid Platform = "android"
	PlatformIOS     Platform = "ios"
)

// UnmarshalText accepts only the Platform values.
func (p *Platform) UnmarshalText(b []byte) (err error) {
	*p, err = parseEnum(b, PlatformAndroid, PlatformIOS)
	return err
}

// PackageType is a package type (§9.5).
type PackageType string

// PackageType values.
const (
	PackagePrayerProfiles     PackageType = "prayer_profiles"
	PackageTzdata             PackageType = "tzdata"
	PackageTzPolygons         PackageType = "tz_polygons"
	PackageCountryPolygons    PackageType = "country_polygons"
	PackageGazetteer          PackageType = "gazetteer"
	PackageHijri              PackageType = "hijri"
	PackageAthanAudioManifest PackageType = "athan_audio_manifest"
)

// UnmarshalText accepts only the PackageType values.
func (p *PackageType) UnmarshalText(b []byte) (err error) {
	*p, err = parseEnum(b, PackagePrayerProfiles, PackageTzdata, PackageTzPolygons, PackageCountryPolygons,
		PackageGazetteer, PackageHijri, PackageAthanAudioManifest)
	return err
}

// HealthState is an Athan Health state (§8.3).
type HealthState string

// HealthState values.
const (
	HealthReady    HealthState = "READY"
	HealthLimited  HealthState = "LIMITED"
	HealthNotReady HealthState = "NOT_READY"
	HealthUnknown  HealthState = "UNKNOWN"
)

// UnmarshalText accepts only the HealthState values.
func (h *HealthState) UnmarshalText(b []byte) (err error) {
	*h, err = parseEnum(b, HealthReady, HealthLimited, HealthNotReady, HealthUnknown)
	return err
}

func parseEnum[T ~string](b []byte, allowed ...T) (T, error) {
	value := T(b)
	if !slices.Contains(allowed, value) {
		var zero T
		return zero, fmt.Errorf("%w %q", ErrUnknownEnum, b)
	}
	return value, nil
}
