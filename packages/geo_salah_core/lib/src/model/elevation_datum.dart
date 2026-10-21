/// Vertical datum of an elevation sample (§6.2).
enum ElevationDatum {
  /// Height above the WGS84 ellipsoid.
  wgs84Ellipsoid,

  /// Height above the EGM2008 geoid.
  egm2008,

  /// Datum not known.
  unknown,
}
