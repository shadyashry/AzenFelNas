import 'package:dm_core_types/src/codes/failure_code.dart';

/// A typed failure carried by `Err` across a layer boundary (REQ-ERR-001).
///
/// Each layer declares its own sealed failure hierarchy implementing this
/// interface; the application layer maps every failure to a user-facing
/// state (DESIGN.md §10.2). [code] is always one of the Appendix J codes
/// (REQ-ERR-002).
abstract interface class Failure {
  /// The Appendix J code that identifies this failure.
  FailureCode get code;
}
