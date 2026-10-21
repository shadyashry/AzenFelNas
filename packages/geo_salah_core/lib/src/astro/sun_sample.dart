/// The slowly varying solar quantities the day model interpolates (§6.4 ¶2).
typedef SunSample = ({
  double declinationDeg,
  double equationOfTimeDeg,
  double radiusAu,
});
