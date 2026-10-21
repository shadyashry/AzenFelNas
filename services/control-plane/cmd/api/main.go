// Command api is the composition root of the Daily Muslim control plane
// (DESIGN.md §9.3, ADR-010). The HTTP API arrives in slice S26.
package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	os.Exit(run(os.Stderr))
}

// run starts the control plane and returns the process exit code.
// Nothing is served before slice S26, so it reports that and returns 2.
func run(stderr io.Writer) int {
	if _, err := fmt.Fprintln(stderr, "control-plane: not implemented yet (slice S26)"); err != nil {
		return 1
	}
	return 2
}
