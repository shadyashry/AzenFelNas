import 'dart:math' as math;

/// Degrees → radians.
double degToRad(double degrees) => degrees * (math.pi / 180);

/// Radians → degrees.
double radToDeg(double radians) => radians * (180 / math.pi);

/// [degrees] limited to `[0, 360)` (SPA paper step 3.2.6).
double limitTo360(double degrees) => degrees % 360;

/// [degrees] wrapped to `[−180, 180)`.
double wrapTo180(double degrees) => (degrees + 180) % 360 - 180;
