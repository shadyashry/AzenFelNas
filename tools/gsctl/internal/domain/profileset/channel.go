package profileset

import "fmt"

// Channel is a distribution channel (§9.1).
type Channel string

// The four channels.
const (
	ChannelDev        Channel = "dev"
	ChannelLab        Channel = "lab"
	ChannelBeta       Channel = "beta"
	ChannelProduction Channel = "production"
)

// ParseChannel returns the channel named s.
func ParseChannel(s string) (Channel, error) {
	switch c := Channel(s); c {
	case ChannelDev, ChannelLab, ChannelBeta, ChannelProduction:
		return c, nil
	default:
		return "", fmt.Errorf("unknown channel %q (want dev, lab, beta or production)", s)
	}
}

// releasesToUsers reports whether the channel reaches users outside the
// team: beta and production refuse unreviewed profiles (Appendix E).
func (c Channel) releasesToUsers() bool {
	switch c {
	case ChannelBeta, ChannelProduction:
		return true
	case ChannelDev, ChannelLab:
		return false
	default:
		return true
	}
}
