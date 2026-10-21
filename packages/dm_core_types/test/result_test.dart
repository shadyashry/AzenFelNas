import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

final class _TestFailure implements Failure {
  const new(this.code);

  @override
  final FailureCode code;
}

const _failure = _TestFailure(FailureCode.profileNotFound);

void main() {
  group('Result (REQ-ERR-001)', () {
    test('ok and err factories build the matching variant (REQ-ERR-001)', () {
      // Arrange / Act
      const ok = Result<int, Failure>.ok(1);
      const err = Result<int, Failure>.err(_failure);

      // Assert
      expect(ok, isA<Ok<int, Failure>>());
      expect(err, isA<Err<int, Failure>>());
    });

    test('exhaustive switch reads the value or the failure (REQ-ERR-001)', () {
      // Arrange
      const results = <Result<int, Failure>>[Ok(7), Err(_failure)];

      // Act
      final described = [
        for (final result in results)
          switch (result) {
            Ok(:final value) => 'ok $value',
            Err(:final failure) => 'err ${failure.code.wire}',
          },
      ];

      // Assert
      expect(described, ['ok 7', 'err PROFILE_NOT_FOUND']);
    });

    test('map transforms Ok and passes Err through (REQ-ERR-001)', () {
      // Arrange
      const Result<int, Failure> ok = Ok(2);
      const Result<int, Failure> err = Err(_failure);

      // Act / Assert
      expect(ok.map((v) => v * 10), const Ok<int, Failure>(20));
      expect(err.map((v) => v * 10), const Err<int, Failure>(_failure));
    });

    test('mapFailure transforms Err and passes Ok through (REQ-ERR-001)', () {
      // Arrange
      const Result<int, Failure> ok = Ok(2);
      const Result<int, Failure> err = Err(_failure);

      // Act / Assert
      expect(ok.mapFailure((f) => f.code), const Ok<int, FailureCode>(2));
      expect(
        err.mapFailure((f) => f.code),
        const Err<int, FailureCode>(FailureCode.profileNotFound),
      );
    });

    test('flatMap chains Ok and short-circuits on Err (REQ-ERR-001)', () {
      // Arrange
      var calls = 0;
      Result<int, Failure> next(int v) {
        calls++;
        return Ok(v + 1);
      }

      // Act
      final fromOk = const Result<int, Failure>.ok(1).flatMap(next);
      final fromErr = const Result<int, Failure>.err(_failure).flatMap(next);

      // Assert
      expect(fromOk, const Ok<int, Failure>(2));
      expect(fromErr, const Err<int, Failure>(_failure));
      expect(calls, 1);
    });

    test('variants compare by value (REQ-ERR-001)', () {
      expect(const Ok<int, Failure>(1), const Ok<int, Failure>(1));
      expect(const Ok<int, Failure>(1), isNot(const Ok<int, Failure>(2)));
      expect(
        const Ok<int, Failure>(1).hashCode,
        const Ok<int, Failure>(1).hashCode,
      );
      expect(
        const Err<int, Failure>(_failure),
        const Err<int, Failure>(_failure),
      );
    });
  });
}
