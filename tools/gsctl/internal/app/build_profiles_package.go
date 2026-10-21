package app

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/dmpkg"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// BuildProfilesPackage compiles the profiles into a `prayer_profiles`
// .dmpkg, stores it under its content address and stages its target for
// the next targets signature (§9.2, §15 D60).
type BuildProfilesPackage struct {
	Source   ports.ProfileSource
	Packages ports.PackageWriter
	Stager   ports.TargetStager
}

// BuildRequest is the channel the set must be valid for and the release.
type BuildRequest struct {
	Channel profileset.Channel
	Release profileset.Release
}

// Built is the staged target.
type Built struct {
	Name     string
	Target   tuf.Target
	Profiles int
}

// Run builds and stages the package; nothing is written when the set or
// the release is invalid.
func (u BuildProfilesPackage) Run(ctx context.Context, req BuildRequest) (Built, error) {
	set, err := ValidateProfiles{Source: u.Source}.Run(ctx, req.Channel)
	if err != nil {
		return Built{}, err
	}
	container, err := dmpkg.Pack(profileset.PayloadFileName, set.Payload)
	if err != nil {
		return Built{}, err
	}
	name, target, err := set.Target(req.Release, container)
	if err != nil {
		return Built{}, err
	}
	if err := u.Packages.WritePackage(ctx, name, target.SHA256, container); err != nil {
		return Built{}, fmt.Errorf("store %s: %w", name, err)
	}
	if err := u.Stager.StageTarget(ctx, name, target); err != nil {
		return Built{}, fmt.Errorf("stage %s: %w", name, err)
	}
	return Built{Name: name, Target: target, Profiles: len(set.Profiles)}, nil
}
