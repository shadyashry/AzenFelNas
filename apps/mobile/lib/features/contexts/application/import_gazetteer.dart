import 'package:daily_muslim/features/contexts/domain/gazetteer_failure.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Imports an activated `gazetteer` package into the database (§7.3: the
/// `gazetteer` table is filled at package activation).
final class ImportGazetteer {
  /// Decodes with [_decoder] and stores with [_store].
  const new(this._decoder, this._store);

  final DecodeGazetteerPayload _decoder;
  final StoreGazetteer _store;

  /// Replaces the stored places with those of [payload] and returns their
  /// number. A payload that does not decode stores nothing, and a failed
  /// write keeps the previous places (REQ-PKG-001).
  Future<Result<int, GazetteerFailure>> call(List<int> payload) async =>
      switch (_decoder.decode(payload)) {
        Ok(:final value) => await _store.replaceAll(value),
        Err(:final failure) => Err(failure),
      };
}
