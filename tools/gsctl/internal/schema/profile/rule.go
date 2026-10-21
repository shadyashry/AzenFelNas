package profile

import (
	"errors"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"
)

// ErrUnknownRule is returned for a rule whose "type" is not a rule kind.
var ErrUnknownRule = errors.New("profile: unknown rule type")

// ErrEmptyRule is returned when encoding a Rule without a variant.
var ErrEmptyRule = errors.New("profile: rule has no variant")

// Rule is an event rule (§6.2 EventRule, Appendix A $defs/rule), encoded
// with its "type" discriminator. Variant is never nil after decoding. Holds
// data only: no rule value is defined in code (§0.2 rule 1).
type Rule struct {
	Variant RuleVariant
}

// RuleVariant is implemented by the six rule kinds only.
type RuleVariant interface {
	ruleType() string
}

// SolarAltitudeRule is "solarAltitude": geometric solar altitude of -Degrees.
type SolarAltitudeRule struct {
	Degrees float64 `json:"degrees"`
}

// TransitRule is "transit": solar transit plus OffsetMinutes.
type TransitRule struct {
	OffsetMinutes *int `json:"offsetMinutes,omitempty"`
}

// ShadowFactorRule is "shadowFactor": Asr with shadow factor K.
type ShadowFactorRule struct {
	K int `json:"k"`
}

// HorizonRule is "horizon": sunrise/sunset with optional refraction and
// semidiameter; unset values are absent, never defaulted here.
type HorizonRule struct {
	RefractionArcmin   *float64 `json:"refractionArcmin,omitempty"`
	SemidiameterArcmin *float64 `json:"semidiameterArcmin,omitempty"`
}

// IntervalAfterRule is "intervalAfter": Minutes after Base.
type IntervalAfterRule struct {
	Base    IntervalBase `json:"base"`
	Minutes int          `json:"minutes"`
}

// IntervalBeforeRule is "intervalBefore": Minutes before Base.
type IntervalBeforeRule struct {
	Base    IntervalBase `json:"base"`
	Minutes int          `json:"minutes"`
}

func (SolarAltitudeRule) ruleType() string  { return "solarAltitude" }
func (TransitRule) ruleType() string        { return "transit" }
func (ShadowFactorRule) ruleType() string   { return "shadowFactor" }
func (HorizonRule) ruleType() string        { return "horizon" }
func (IntervalAfterRule) ruleType() string  { return "intervalAfter" }
func (IntervalBeforeRule) ruleType() string { return "intervalBefore" }

// MarshalJSON encodes the variant with its "type".
func (r Rule) MarshalJSON() ([]byte, error) {
	if r.Variant == nil {
		return nil, ErrEmptyRule
	}
	return jsonx.WithTag("type", r.Variant.ruleType(), r.Variant)
}

// UnmarshalJSON decodes the variant named by "type", rejecting unknown keys.
func (r *Rule) UnmarshalJSON(data []byte) error {
	tag, rest, err := jsonx.SplitTag(data, "type")
	if err != nil {
		return err
	}
	switch tag {
	case "solarAltitude":
		return decodeRule[SolarAltitudeRule](rest, r)
	case "transit":
		return decodeRule[TransitRule](rest, r)
	case "shadowFactor":
		return decodeRule[ShadowFactorRule](rest, r)
	case "horizon":
		return decodeRule[HorizonRule](rest, r)
	case "intervalAfter":
		return decodeRule[IntervalAfterRule](rest, r)
	case "intervalBefore":
		return decodeRule[IntervalBeforeRule](rest, r)
	default:
		return fmt.Errorf("%w %q", ErrUnknownRule, tag)
	}
}

func decodeRule[V RuleVariant](data []byte, r *Rule) error {
	var v V
	if err := jsonx.DecodeStrict(data, &v); err != nil {
		return err
	}
	r.Variant = v
	return nil
}
