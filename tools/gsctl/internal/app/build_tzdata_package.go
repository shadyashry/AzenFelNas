package app

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/dmpkg"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/tzdatapkg"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/pipeline"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// BuildTzdataPackage packs the data pipeline's `.tzf` payload into a
// `tzdata` .dmpkg, stores it under its content address and stages its
// target (§9.5, §15 D69). The pipeline's manifest must vouch for the bytes.
type BuildTzdataPackage struct {
	Packages ports.PackageWriter
	Stager   ports.TargetStager
}

// TzdataBuildRequest is the pipeline output and the release.
type TzdataBuildRequest struct {
	Payload  []byte
	Manifest []byte
	Release  profileset.Release
	// MinApp is the oldest app version that reads the payload.
	MinApp string
}

// TzdataBuilt is the staged target.
type TzdataBuilt struct {
	Name   string
	Target tuf.Target
	Zones  int
}

// Run builds and stages the package; nothing is written when the payload,
// the manifest or the release is invalid.
func (u BuildTzdataPackage) Run(ctx context.Context, req TzdataBuildRequest) (TzdataBuilt, error) {
	var manifest pipeline.Manifest
	if err := json.Unmarshal(req.Manifest, &manifest); err != nil {
		return TzdataBuilt{}, fmt.Errorf("%w: %w", tzdatapkg.ErrManifest, err)
	}
	zones, err := tzdatapkg.CheckBuild(req.Payload, manifest, req.Release.Version)
	if err != nil {
		return TzdataBuilt{}, err
	}
	container, err := dmpkg.Pack(tzdatapkg.PayloadFileName, req.Payload)
	if err != nil {
		return TzdataBuilt{}, err
	}
	name, target, err := tzdatapkg.Target(req.Release, req.MinApp, container)
	if err != nil {
		return TzdataBuilt{}, err
	}
	if err := u.Packages.WritePackage(ctx, name, target.SHA256, container); err != nil {
		return TzdataBuilt{}, fmt.Errorf("store %s: %w", name, err)
	}
	if err := u.Stager.StageTarget(ctx, name, target); err != nil {
		return TzdataBuilt{}, fmt.Errorf("stage %s: %w", name, err)
	}
	return TzdataBuilt{Name: name, Target: target, Zones: zones}, nil
}
