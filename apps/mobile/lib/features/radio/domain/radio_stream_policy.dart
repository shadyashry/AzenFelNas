/// Which stream addresses may be played (§15 D122, REQ-RADIO-004): HTTPS on
/// MP3Quran's own hosts only. A station of another broadcaster in the
/// catalog is left out until it is reviewed on its own.
abstract final class RadioStreamPolicy {
  /// The registrable domains MP3Quran serves its own stations from.
  static const Set<String> domains = {'mp3quran.net', 'qurango.net'};

  /// Whether [url] may be played.
  static bool allows(Uri url) {
    if (url.scheme != 'https' || url.hasPort && url.port != 443) return false;
    if (url.userInfo.isNotEmpty) return false;
    final host = url.host.toLowerCase();
    return domains.any((d) => host == d || host.endsWith('.$d'));
  }
}
