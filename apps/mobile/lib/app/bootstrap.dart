import 'dart:io';

import 'package:daily_muslim/app/daily_muslim_app.dart';
import 'package:daily_muslim/app/di.dart';
import 'package:daily_muslim/app/startup_failure_app.dart';
import 'package:daily_muslim/features/contexts/data/geolocator_device_locator.dart';
import 'package:daily_muslim/features/contexts/data/permission_handler_location_access.dart';
import 'package:daily_muslim/features/qibla/data/channel_heading_source.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/storage/data/database_files.dart';
import 'package:daily_muslim/features/storage/data/method_channel_backup_exclusion.dart';
import 'package:daily_muslim/features/storage/data/static_rules_backup_exclusion.dart';
import 'package:daily_muslim/features/storage/domain/exclude_from_backup.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

/// Opens the databases with the platform adapters and returns the widget to
/// run: the app, or the start-up failure screen.
abstract final class Bootstrap {
  /// The root widget for this process.
  static Future<Widget> run() async {
    final open = DatabaseFiles(
      supportDirectory: getApplicationSupportDirectory,
      excludeFromBackup: _exclusion(),
      executorFor: (file) => driftDatabase(
        name: file.uri.pathSegments.last,
        native: DriftNativeOptions(databasePath: () async => file.path),
      ),
    );
    switch (await open()) {
      case Err(:final failure):
        return StartupFailureApp(const DescribeFailure()(failure));
      case Ok(:final value):
        final support = await getApplicationSupportDirectory();
        return ProviderScope(
          overrides: AppBindings.of(
            databases: value,
            assets: rootBundle,
            clock: const SystemClock(),
            blobRoot: Directory('${support.path}/packages'),
            locator: GeolocatorDeviceLocator(GeolocatorPlatform.instance),
            locationAccess: PermissionHandlerLocationAccess(
              PermissionHandlerPlatform.instance,
            ),
            heading: const ChannelHeadingSource(),
          ),
          child: const DailyMuslimApp(),
        );
    }
  }

  static ExcludeFromBackup _exclusion() => switch (defaultTargetPlatform) {
    TargetPlatform.iOS ||
    TargetPlatform.macOS => const MethodChannelBackupExclusion(),
    TargetPlatform.android ||
    TargetPlatform.fuchsia ||
    TargetPlatform.linux ||
    TargetPlatform.windows => const StaticRulesBackupExclusion(),
  };
}
