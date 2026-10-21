// Package sysclock is the ports.Clock that reads the host clock, in UTC.
package sysclock

import "time"

// Clock reads time.Now.
type Clock struct{}

// Now implements ports.Clock.
func (Clock) Now() time.Time { return time.Now().UTC() }
