/// The global pre-reminder offset (§7.7, REQ-ALM-042): one of the allowed
/// minute values, so an invalid offset cannot be represented.
enum PreReminder {
  /// No pre-reminder (the default).
  off(0),

  /// Five minutes before.
  five(5),

  /// Ten minutes before.
  ten(10),

  /// Fifteen minutes before.
  fifteen(15),

  /// Thirty minutes before.
  thirty(30);

  new(this.minutes);

  /// Minutes before the Athan; 0 for [off].
  final int minutes;

  /// The offset of [minutes], or null when it is not an allowed value.
  static PreReminder? ofMinutes(int minutes) {
    for (final value in values) {
      if (value.minutes == minutes) return value;
    }
    return null;
  }
}
