/// Where an active package came from (§7.3 `active_packages.source`).
enum PackageSource {
  /// Shipped in the binary under `assets/packages/` (REQ-PKG-003).
  bundled('bundled'),

  /// Downloaded from the CDN and verified (REQ-PKG-001).
  downloaded('downloaded');

  new(this.wire);

  /// The stored name.
  final String wire;

  /// The source stored as [wire]; null for anything else.
  static PackageSource? fromWire(String wire) => switch (wire) {
    'bundled' => bundled,
    'downloaded' => downloaded,
    _ => null,
  };
}
