import 'package:meta/meta.dart';

/// The display values a status line may need beyond its label (§18.5),
/// already localised by the caller (names, dates formatted with the
/// app's pinned TZDB). A missing value shortens the line, never invents.
@immutable
final class StatusDetails {
  /// Creates the details.
  const new({this.authorityName, this.sourceName, this.date, this.reason});

  /// `<authority>` of "Authority aligned".
  final String? authorityName;

  /// `<source>` of "Verified".
  final String? sourceName;

  /// `<date>` of "Verified" and "Observed".
  final String? date;

  /// `<reason>` of "Unknown"; must contain no digit.
  final String? reason;
}
