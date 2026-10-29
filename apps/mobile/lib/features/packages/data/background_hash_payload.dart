import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/packages/domain/run_payload_work.dart';
import 'package:dm_packages/dm_packages.dart';

/// [HashPayload] through [RunPayloadWork], a background isolate by default:
/// the bundled payloads are up to 8 MB and are re-hashed at every start
/// (REQ-DIST-003), which must not block the UI isolate (§15 D96).
final class BackgroundHashPayload implements HashPayload {
  /// The hasher over [_run].
  const new({this._run = Isolate.run});

  final RunPayloadWork _run;

  @override
  Future<String> call(List<int> bytes) {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    return _run(() => sha256.convert(data).toString());
  }
}
