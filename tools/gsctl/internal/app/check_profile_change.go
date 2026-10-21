package app

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// CheckProfileChange applies the §9.2 pull-request rule: no angle change in
// a PR that also touches tz/coordinate data (§15 D64).
type CheckProfileChange struct {
	Base    ports.ProfileSource
	Head    ports.ProfileSource
	Changes ports.ChangedPaths
}

// Run returns nil when the PR may proceed, otherwise an error wrapping
// profileset.ErrInvalid that names both sides.
func (u CheckProfileChange) Run(ctx context.Context) error {
	base, err := u.Base.LoadProfiles(ctx)
	if err != nil {
		return fmt.Errorf("load base profiles: %w", err)
	}
	head, err := u.Head.LoadProfiles(ctx)
	if err != nil {
		return fmt.Errorf("load profiles: %w", err)
	}
	changed, err := u.Changes.ChangedPaths(ctx)
	if err != nil {
		return err
	}
	if problems := profileset.CheckChange(base, head, changed); len(problems) > 0 {
		return &profileset.ValidationError{Problems: problems}
	}
	return nil
}
