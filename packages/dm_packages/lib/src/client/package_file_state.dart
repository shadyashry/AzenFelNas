/// The life cycle of one package file (§7.3 `package_files.state`):
/// `staged` → `active` → `previous` → `garbage`, deleted 7 days later.
enum PackageFileState {
  /// Verified and stored, not yet active.
  staged('staged'),

  /// The version in `active_packages`.
  active('active'),

  /// The version before the active one: the rollback target.
  previous('previous'),

  /// Superseded, refused after activation or rolled back from; deleted by
  /// `CollectPackageGarbage` 7 days after it became garbage.
  garbage('garbage');

  new(this.wire);

  /// The stored name.
  final String wire;

  /// The state stored as [wire]; null for anything else.
  static PackageFileState? fromWire(String wire) {
    for (final state in values) {
      if (state.wire == wire) return state;
    }
    return null;
  }
}
