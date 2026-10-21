/// The solar altitude as a function of time, as the root solver consumes it
/// (consumer-defined port, §17.1 I).
///
/// Contract: both functions are continuous on the source's domain, defined in
/// UTC epoch milliseconds (fractional allowed), return geometric degrees and
/// are pure. [altitudeDeg] is the fast path the solver brackets and iterates
/// on; [exactAltitudeDeg] is the reference it refines a converged root with,
/// once per root (§6.4 ¶2). The two agree to well under 0.001°.
abstract interface class AltitudeSource {
  /// Fast altitude at [utcMs], degrees.
  double altitudeDeg(double utcMs);

  /// Exact altitude at [utcMs], degrees.
  double exactAltitudeDeg(double utcMs);
}
