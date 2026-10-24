package app

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// PurgeExpired deletes every row past its §9.3 retention (REQ-DATA-002,
// REQ-PRIV-007). The `purge` job runs it hourly.
type PurgeExpired struct {
	Purger ports.Purger
	Clock  ports.Clock
}

// Execute returns what was deleted.
func (u PurgeExpired) Execute(ctx context.Context) (domain.PurgeCounts, error) {
	counts, err := u.Purger.Purge(ctx, domain.CutoffsAt(u.Clock.Now()))
	if err != nil {
		return domain.PurgeCounts{}, fmt.Errorf("purge: %w", err)
	}
	return counts, nil
}
