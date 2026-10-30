/// Pigeon platform contracts and shared JSON models between Dart, Kotlin and
/// Swift (DESIGN.md §7.8).
///
/// Flutter package. Holds the plan, snapshot, event-log, telemetry, gazetteer
/// and audio-manifest wire models since S02; pigeon contracts arrive in S20;
/// the diagnostic-bundle models in S24.
library;

export 'package:dm_contracts/src/audio/athan_audio_manifest.dart';
export 'package:dm_contracts/src/audio/athan_ios_clip.dart';
export 'package:dm_contracts/src/audio/athan_sound.dart';
export 'package:dm_contracts/src/diagnostics/diagnostic_bundle.dart';
export 'package:dm_contracts/src/diagnostics/diagnostic_context.dart';
export 'package:dm_contracts/src/diagnostics/diagnostic_device.dart';
export 'package:dm_contracts/src/diagnostics/diagnostic_files.dart';
export 'package:dm_contracts/src/diagnostics/diagnostic_health.dart';
export 'package:dm_contracts/src/diagnostics/diagnostic_package.dart';
export 'package:dm_contracts/src/diagnostics/diagnostic_plan.dart';
export 'package:dm_contracts/src/event_log/event_code_converter.dart';
export 'package:dm_contracts/src/event_log/event_log_attrs.dart';
export 'package:dm_contracts/src/event_log/event_log_entry.dart';
export 'package:dm_contracts/src/event_log/event_log_level.dart';
export 'package:dm_contracts/src/event_log/failure_code_converter.dart';
export 'package:dm_contracts/src/gazetteer/gazetteer_alt_names.dart';
export 'package:dm_contracts/src/gazetteer/gazetteer_place.dart';
export 'package:dm_contracts/src/quran/quran_edition.dart';
export 'package:dm_contracts/src/quran/quran_package_file.dart';
export 'package:dm_contracts/src/quran/quran_package_manifest.dart';
export 'package:dm_contracts/src/quran/quran_page_image.dart';
export 'package:dm_contracts/src/quran/quran_source.dart';
export 'package:dm_contracts/src/quran/quran_source_role.dart';
export 'package:dm_contracts/src/schedule_plan/localized_text.dart';
export 'package:dm_contracts/src/schedule_plan/plan_locale.dart';
export 'package:dm_contracts/src/schedule_plan/schedule_entry_kind.dart';
export 'package:dm_contracts/src/schedule_plan/schedule_plan.dart';
export 'package:dm_contracts/src/schedule_plan/schedule_plan_entry.dart';
export 'package:dm_contracts/src/schedule_plan/schedule_plan_policy.dart';
export 'package:dm_contracts/src/snapshot/confidence_kind_code.dart';
export 'package:dm_contracts/src/snapshot/health_state_code.dart';
export 'package:dm_contracts/src/snapshot/sky_phase_code.dart';
export 'package:dm_contracts/src/snapshot/sky_segment.dart';
export 'package:dm_contracts/src/snapshot/snapshot.dart';
export 'package:dm_contracts/src/snapshot/snapshot_confidence.dart';
export 'package:dm_contracts/src/snapshot/snapshot_health.dart';
export 'package:dm_contracts/src/snapshot/snapshot_item.dart';
export 'package:dm_contracts/src/telemetry/package_type_code.dart';
export 'package:dm_contracts/src/telemetry/sync_outcome_counts.dart';
export 'package:dm_contracts/src/telemetry/telemetry_aggregate.dart';
export 'package:dm_contracts/src/telemetry/telemetry_counters.dart';
export 'package:dm_contracts/src/telemetry/telemetry_platform.dart';
export 'package:dm_contracts/src/telemetry/test_result_counts.dart';
