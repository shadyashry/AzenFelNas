/// One data source the app ships and its licence notice (§10.4).
final class Attribution {
  /// The entry.
  const new({
    required this.package,
    required this.name,
    required this.licence,
    required this.notice,
  });

  /// The package type that carries the data.
  final String package;

  /// The source's name.
  final String name;

  /// SPDX id, or `public-domain`.
  final String licence;

  /// The notice the licence asks for, verbatim.
  final String notice;
}
