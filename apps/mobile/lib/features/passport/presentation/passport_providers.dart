import 'package:daily_muslim/features/passport/application/import_calculation_link.dart';
import 'package:daily_muslim/features/passport/application/resolve_calculation_id.dart';
import 'package:daily_muslim/features/passport/domain/calculation_link.dart';
import 'package:daily_muslim/features/passport/presentation/passport_state.dart';
import 'package:daily_muslim/features/passport/presentation/passport_view.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

/// The Passport of [CalculationRoute] (§6.4 ¶11): this device's schedule
/// first; otherwise the link's inputs, recomputed here.
final ProviderFamily<PassportState, CalculationRoute> passportStateProvider =
    Provider.family<PassportState, CalculationRoute>((
      ref,
      route,
    ) {
      switch (ref.watch(scheduleProvider)) {
        case AsyncLoading():
          return const PassportLoading();
        case AsyncError(:final error, :final stackTrace):
          Error.throwWithStackTrace(error, stackTrace);
        case AsyncData(value: Ok(value: final loaded)):
          final tzdb = loaded.data.tzdb;
          final entry = ResolveCalculationId(tzdb)(
            loaded.schedule,
            route.calculationId,
            event: route.event,
          );
          if (entry != null) return PassportReady(PassportView.of(entry, tzdb));
        case AsyncData(value: Err()):
          break;
      }
      final inputs = switch (route.inputs) {
        final String encoded => CalculationLink.decode(encoded),
        null => null,
      };
      if (inputs == null) return const PassportNotFound();
      switch (ref.watch(runtimeDataProvider)) {
        case AsyncLoading():
          return const PassportLoading();
        case AsyncError(:final error, :final stackTrace):
          Error.throwWithStackTrace(error, stackTrace);
        case AsyncData(value: Err()):
          return const PassportNotFound();
        case AsyncData(value: Ok(value: final data)):
          final import = ImportCalculationLink(data.tzdb, data.profiles);
          return switch (import(
            route.calculationId,
            inputs,
            event: route.event,
          )) {
            ImportMatched(:final entry) => PassportReady(
              PassportView.of(entry, data.tzdb),
            ),
            ImportMismatched(:final mismatch) => PassportImportMismatch(
              mismatch,
            ),
            null => const PassportNotFound(),
          };
      }
    });
