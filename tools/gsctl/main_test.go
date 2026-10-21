package main

import (
	"bytes"
	"testing"
)

func TestRunWithoutCommandsReturnsUsageExitCode(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name string
		args []string
	}{
		{name: "no arguments", args: nil},
		{name: "unknown command", args: []string{"sign"}},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			var stderr bytes.Buffer
			if got := run(tc.args, &stderr); got != 2 {
				t.Fatalf("run(%v) = %d, want 2", tc.args, got)
			}
			if stderr.Len() == 0 {
				t.Fatal("run printed no usage message")
			}
		})
	}
}
