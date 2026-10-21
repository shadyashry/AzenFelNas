/// The worked example of the SPA paper (Reda & Andreas, NREL/TP-560-34302,
/// §A.5): Golden, Colorado, 17 October 2003, 12:30:30 local standard time
/// (UTC−7), ΔT = 67 s.
library;

/// 2003-10-17T19:30:30Z in UTC epoch milliseconds.
const double paperExampleUtcMs = 1066419030000;

/// ΔT used by the example, seconds.
const double paperExampleDeltaTSeconds = 67;

/// Observer latitude, degrees north.
const double paperExampleLatitudeDeg = 39.742476;

/// Observer longitude, degrees east.
const double paperExampleLongitudeDeg = -105.1786;

/// Observer elevation, metres.
const double paperExampleElevationM = 1830.14;
