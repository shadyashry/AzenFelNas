import 'package:meta/meta.dart';

/// Why the station list could not be refreshed (§15 D122). The list kept on
/// the phone stays in use whichever it is.
@immutable
sealed class RadioCatalogFailure {
  const new();
}

/// No connection, or the connection broke.
final class RadioCatalogOffline extends RadioCatalogFailure {
  /// The failure.
  const new();
}

/// No answer in time.
final class RadioCatalogTimedOut extends RadioCatalogFailure {
  /// The failure.
  const new();
}

/// The provider answered with an error status.
final class RadioCatalogRefused extends RadioCatalogFailure {
  /// The failure for HTTP [status].
  const new(this.status);

  /// The HTTP status.
  final int status;

  @override
  bool operator ==(Object other) =>
      other is RadioCatalogRefused && other.status == status;

  @override
  int get hashCode => status.hashCode;
}

/// The answer was not a station list the app can read.
final class RadioCatalogMalformed extends RadioCatalogFailure {
  /// The failure, with a short [detail] for tests (never shown).
  const new(this.detail);

  /// What was wrong.
  final String detail;

  @override
  bool operator ==(Object other) =>
      other is RadioCatalogMalformed && other.detail == detail;

  @override
  int get hashCode => detail.hashCode;
}

/// The request was cancelled (a newer refresh, or the app closing it).
final class RadioCatalogCancelled extends RadioCatalogFailure {
  /// The failure.
  const new();
}
