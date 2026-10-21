/// One problem reported by a repository check.
final class Finding {
  /// Creates a finding at [path]:[line] for [rule].
  const new({
    required this.path,
    required this.line,
    required this.rule,
    required this.message,
  });

  /// Repository-relative path with forward slashes.
  final String path;

  /// 1-based line number, or 0 when the finding concerns a whole file.
  final int line;

  /// Stable rule identifier, for example `pure-import`.
  final String rule;

  /// Human-readable explanation, including how to fix it.
  final String message;

  @override
  String toString() => '$path:$line: [$rule] $message';
}
