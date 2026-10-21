package profile

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"
)

// ErrUnknownMethod is returned for a value that is not a high-latitude method.
var ErrUnknownMethod = errors.New("profile: unknown high-latitude method")

// HighLatitudeMethod is one entry of the high-latitude chain (§6.4 ¶7):
// a bare string for parameterless methods, a one-key object otherwise.
// Variant is never nil after decoding.
type HighLatitudeMethod struct {
	Variant HighLatitudeVariant
}

// HighLatitudeVariant is implemented by the five methods only.
type HighLatitudeVariant interface {
	methodName() string
}

// AnglePortion is "anglePortion".
type AnglePortion struct{}

// MiddleOfNight is "middleOfNight".
type MiddleOfNight struct{}

// SeventhOfNight is "seventhOfNight".
type SeventhOfNight struct{}

// NearestLatitude is {"nearestLatitude": {"latDeg": …}}.
type NearestLatitude struct {
	LatDeg float64 `json:"latDeg"`
}

// NearestValidDay is {"nearestValidDay": {"maxDays": …}}.
type NearestValidDay struct {
	MaxDays int `json:"maxDays"`
}

func (AnglePortion) methodName() string    { return "anglePortion" }
func (MiddleOfNight) methodName() string   { return "middleOfNight" }
func (SeventhOfNight) methodName() string  { return "seventhOfNight" }
func (NearestLatitude) methodName() string { return "nearestLatitude" }
func (NearestValidDay) methodName() string { return "nearestValidDay" }

// MarshalJSON encodes the method in its schema form.
func (m HighLatitudeMethod) MarshalJSON() ([]byte, error) {
	switch v := m.Variant.(type) {
	case AnglePortion, MiddleOfNight, SeventhOfNight:
		return json.Marshal(v.methodName())
	case NearestLatitude, NearestValidDay:
		return json.Marshal(map[string]HighLatitudeVariant{v.methodName(): v})
	default:
		return nil, fmt.Errorf("%w %T", ErrUnknownMethod, m.Variant)
	}
}

// UnmarshalJSON decodes either form, rejecting unknown names and keys.
func (m *HighLatitudeMethod) UnmarshalJSON(data []byte) error {
	if bytes.HasPrefix(bytes.TrimSpace(data), []byte(`"`)) {
		var name string
		if err := json.Unmarshal(data, &name); err != nil {
			return fmt.Errorf("decode method name: %w", err)
		}
		switch name {
		case "anglePortion":
			m.Variant = AnglePortion{}
		case "middleOfNight":
			m.Variant = MiddleOfNight{}
		case "seventhOfNight":
			m.Variant = SeventhOfNight{}
		default:
			return fmt.Errorf("%w %q", ErrUnknownMethod, name)
		}
		return nil
	}
	var object struct {
		NearestLatitude *NearestLatitude `json:"nearestLatitude"`
		NearestValidDay *NearestValidDay `json:"nearestValidDay"`
	}
	if err := jsonx.DecodeStrict(data, &object); err != nil {
		return err
	}
	switch {
	case object.NearestLatitude != nil && object.NearestValidDay == nil:
		m.Variant = *object.NearestLatitude
	case object.NearestValidDay != nil && object.NearestLatitude == nil:
		m.Variant = *object.NearestValidDay
	default:
		return fmt.Errorf("%w %s", ErrUnknownMethod, data)
	}
	return nil
}
