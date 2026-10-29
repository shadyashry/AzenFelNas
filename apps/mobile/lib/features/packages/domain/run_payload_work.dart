import 'dart:async';

/// Runs CPU-heavy payload work (hashing, decoding): `Isolate.run` in the
/// app, so a multi-megabyte payload never blocks the UI isolate; in place
/// where no second isolate is wanted (§15 D96).
typedef RunPayloadWork = Future<R> Function<R>(FutureOr<R> Function() work);

/// [RunPayloadWork] on the calling isolate.
Future<R> runPayloadWorkInPlace<R>(FutureOr<R> Function() work) async =>
    await work();
