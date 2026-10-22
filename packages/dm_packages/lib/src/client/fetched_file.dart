import 'package:meta/meta.dart';

/// One file as the CDN served it.
@immutable
final class FetchedFile {
  /// [bytes] exactly as received; [serverDateUtcMs] from the HTTP `Date`
  /// header, when present.
  const new(this.bytes, {this.serverDateUtcMs});

  /// The body.
  final List<int> bytes;

  /// The CDN's `Date` header, UTC epoch milliseconds: the clock-integrity
  /// sample of §7.6 (REQ-TIME-010). Null when absent or unparseable.
  final int? serverDateUtcMs;
}
