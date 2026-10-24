package memory_test

import (
	"testing"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/memory"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports/porttest"
)

func TestREQTEST004MemoryStoreContract(t *testing.T) {
	porttest.Run(t, porttest.Harness{
		New: func(*testing.T) porttest.Subject { return memory.New() },
		SeedEvidence: func(_ *testing.T, s porttest.Subject, id, version string, summary []byte) {
			s.(*memory.Store).PutEvidence(id, version, summary)
		},
		CorrectionIDs: func(_ *testing.T, s porttest.Subject) []domain.ReceiptID {
			var ids []domain.ReceiptID
			for _, c := range s.(*memory.Store).Corrections() {
				ids = append(ids, c.ID)
			}
			return ids
		},
		TelemetryCount: func(_ *testing.T, s porttest.Subject, day, metric, dim string) int64 {
			return s.(*memory.Store).TelemetryCount(day, metric, dim)
		},
	})
}
