/// Which polygon package a payload is (§9.5, ADR-015): the layouts are the
/// same and differ in magic and in what the names are.
enum PolygonDataset {
  /// `tz_polygons`: IANA zone ids (timezone-boundary-builder, ODbL).
  tz('TZPG'),

  /// `country_polygons`: ISO 3166-1 alpha-2 codes (Natural Earth admin-0).
  country('CTPG');

  new(this.magic);

  /// The four ASCII bytes the payload starts with.
  final String magic;
}
