// Package app holds the gsctl use cases, one type with one public method
// each (§17.1 S): ValidateProfiles, BuildProfilesPackage, SignRoot,
// SignTargets, SignSnapshot, SignTimestamp and VerifyRepository. They
// depend only on internal/ports and the pure domain.
package app

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// ValidateProfiles checks the profile set for a channel (§15 D61).
type ValidateProfiles struct {
	Source ports.ProfileSource
}

// Run returns the compiled set, or an error wrapping
// profileset.ErrInvalid that lists every problem.
func (u ValidateProfiles) Run(ctx context.Context, channel profileset.Channel) (profileset.Set, error) {
	docs, err := u.Source.LoadProfiles(ctx)
	if err != nil {
		return profileset.Set{}, fmt.Errorf("load profiles: %w", err)
	}
	return profileset.Compile(docs, channel)
}
