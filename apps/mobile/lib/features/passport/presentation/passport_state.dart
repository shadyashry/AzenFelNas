import 'package:daily_muslim/features/passport/domain/import_mismatch.dart';
import 'package:daily_muslim/features/passport/presentation/passport_view.dart';

/// The Accuracy Passport UiState (§18.4): `ready(entry)`,
/// `importMismatch(details)`, `notFound`, plus loading.
sealed class PassportState {
  const new();
}

/// The schedule or the runtime data is still loading.
final class PassportLoading extends PassportState {
  const new();
}

/// The entry, from this device's schedule or a matching import.
final class PassportReady extends PassportState {
  /// Shows [entry].
  const new(this.entry);

  /// What to show.
  final PassportView entry;
}

/// A shared link that this device did not reproduce (§6.4 ¶11).
final class PassportImportMismatch extends PassportState {
  /// Shows [details].
  const new(this.details);

  /// What differs.
  final ImportMismatch details;
}

/// Neither this device's schedule nor the link's inputs give the ID.
final class PassportNotFound extends PassportState {
  const new();
}
