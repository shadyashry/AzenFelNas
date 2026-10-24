package app

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// GetEvidence returns the newest evidence summary of a profile (§9.3).
type GetEvidence struct {
	Store ports.EvidenceStore
}

// Execute returns the summary JSON or domain.ErrNotFound (wrapped).
func (u GetEvidence) Execute(ctx context.Context, profileID string) ([]byte, error) {
	summary, err := u.Store.LatestEvidence(ctx, profileID)
	if err != nil {
		return nil, fmt.Errorf("evidence for %s: %w", profileID, err)
	}
	return summary, nil
}
