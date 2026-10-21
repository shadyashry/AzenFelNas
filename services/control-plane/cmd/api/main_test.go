package main

import (
	"bytes"
	"testing"
)

func TestRunBeforeS26ReportsNotImplemented(t *testing.T) {
	t.Parallel()
	var stderr bytes.Buffer
	if got := run(&stderr); got != 2 {
		t.Fatalf("run() = %d, want 2", got)
	}
	if stderr.Len() == 0 {
		t.Fatal("run printed nothing")
	}
}
