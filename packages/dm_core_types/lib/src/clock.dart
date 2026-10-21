/// Port for reading the current instant.
///
/// Code reads time only through an injected [Clock]; `DateTime.now()`
/// appears nowhere else (DESIGN.md §17.2). The engine never reads a clock:
/// instants are parameters (§6.3).
///
/// Contract, shared by every implementation and checked by the Clock
/// contract tests (REQ-TEST-004): [nowUtcMs] returns milliseconds since
/// 1970-01-01T00:00:00Z, is never negative, does not depend on the device
/// time zone and never throws. Successive calls are not guaranteed to be
/// monotonic, because the device clock can be changed.
abstract interface class Clock {
  /// The current instant as UTC epoch milliseconds.
  int nowUtcMs();
}
