import 'package:meta/meta.dart';

/// The outcome of a fallible operation: [Ok] with a value of type [T] or
/// [Err] with a failure of type [F].
///
/// Every fallible operation that crosses a layer boundary returns a
/// `Result<T, Failure>`; exceptions never cross a layer (REQ-ERR-001).
/// Consume it with an exhaustive `switch`:
///
/// ```dart
/// switch (result) {
///   case Ok(:final value): use(value);
///   case Err(:final failure): report(failure);
/// }
/// ```
///
/// Instances are immutable and compare by value. All methods are pure.
@immutable
sealed class Result<T, F> {
  const new();

  /// A successful result holding [value].
  const factory ok(T value) = Ok<T, F>;

  /// A failed result holding [failure].
  const factory err(F failure) = Err<T, F>;

  /// Applies [transform] to an [Ok] value; an [Err] is passed through.
  Result<U, F> map<U>(U Function(T value) transform) => switch (this) {
    Ok(:final value) => Ok(transform(value)),
    Err(:final failure) => Err(failure),
  };

  /// Applies [transform] to an [Err] failure; an [Ok] is passed through.
  Result<T, G> mapFailure<G>(G Function(F failure) transform) => switch (this) {
    Ok(:final value) => Ok(value),
    Err(:final failure) => Err(transform(failure)),
  };

  /// Runs [next] on an [Ok] value; an [Err] short-circuits and [next] is
  /// not called.
  Result<U, F> flatMap<U>(Result<U, F> Function(T value) next) =>
      switch (this) {
        Ok(:final value) => next(value),
        Err(:final failure) => Err(failure),
      };
}

/// A successful [Result].
final class Ok<T, F> extends Result<T, F> {
  /// Wraps [value].
  const new(this.value);

  /// The produced value.
  final T value;

  @override
  bool operator ==(Object other) => other is Ok<T, F> && other.value == value;

  @override
  int get hashCode => Object.hash(Ok, value);

  @override
  String toString() => 'Ok($value)';
}

/// A failed [Result].
final class Err<T, F> extends Result<T, F> {
  /// Wraps [failure].
  const new(this.failure);

  /// Why the operation failed.
  final F failure;

  @override
  bool operator ==(Object other) =>
      other is Err<T, F> && other.failure == failure;

  @override
  int get hashCode => Object.hash(Err, failure);

  @override
  String toString() => 'Err($failure)';
}
