/// State of the location permission after a request.
enum LocationAccess {
  /// Approximate or precise location may be read.
  granted,

  /// Refused this time; the app may ask again.
  denied,

  /// Refused for good; only the OS settings can grant it.
  permanentlyDenied,

  /// Blocked by policy (parental controls, MDM).
  restricted,
}
