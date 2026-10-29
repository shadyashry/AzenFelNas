import 'dart:async';

import 'package:daily_muslim/features/contexts/data/geolocator_device_locator.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'support/fake_device_locator.dart';

/// What the device does in one contract case.
enum _Device { servicesOff, denied, located, timesOut, noCache }

const _fixMs = 1792670400000;

final _fix = LocationFix(
  point: GeoPointE6(30044420, 31235712),
  horizontalAccuracyM: 1200,
  fixUtcMs: _fixMs,
  isMock: true,
);

/// The plugin's platform channel, scripted: the fake sits below the
/// adapter, so the adapter itself is under test.
final class _ScriptedPlatform extends GeolocatorPlatform {
  new(this.device);

  final _Device device;

  /// Settings of the last `getCurrentPosition`.
  LocationSettings? settings;

  @override
  Future<bool> isLocationServiceEnabled() async =>
      device != _Device.servicesOff;

  @override
  Future<LocationPermission> checkPermission() async => device == _Device.denied
      ? LocationPermission.deniedForever
      : LocationPermission.whileInUse;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    settings = locationSettings;
    if (device == _Device.timesOut) throw TimeoutException('fix');
    return _position;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => device == _Device.noCache ? null : _position;

  static final _position = Position(
    latitude: 30.04442,
    longitude: 31.235712,
    timestamp: DateTime.fromMillisecondsSinceEpoch(_fixMs, isUtc: true),
    accuracy: 1200,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
    isMocked: true,
  );
}

FakeDeviceLocator _fake(_Device device) {
  final fake = FakeDeviceLocator();
  switch (device) {
    case _Device.servicesOff:
      fake
        ..current = const Err(LocationFailure.servicesOff())
        ..lastKnown = const Err(LocationFailure.servicesOff());
    case _Device.denied:
      fake
        ..current = const Err(LocationFailure.permissionDenied())
        ..lastKnown = const Err(LocationFailure.permissionDenied());
    case _Device.located:
      fake
        ..current = Ok(_fix)
        ..lastKnown = Ok(_fix);
    case _Device.timesOut:
      fake
        ..current = const Err(LocationFailure.unavailable('fix timed out'))
        ..lastKnown = Ok(_fix);
    case _Device.noCache:
      fake
        ..current = Ok(_fix)
        ..lastKnown = const Ok(null);
  }
  return fake;
}

void main() {
  final implementations = <String, LocateDevice Function(_Device)>{
    'GeolocatorDeviceLocator': (d) =>
        GeolocatorDeviceLocator(_ScriptedPlatform(d)),
    'FakeDeviceLocator': _fake,
  };

  for (final MapEntry(key: name, value: open) in implementations.entries) {
    group('REQ-TEST-004 LocateDevice port contract: $name', () {
      test('services off fails with LOC_SERVICES_OFF', () async {
        final device = open(_Device.servicesOff);
        expect(
          await device.currentFix(),
          const Err<LocationFix, LocationFailure>(
            LocationFailure.servicesOff(),
          ),
        );
      });

      test('no permission fails with LOC_PERMISSION_DENIED and never '
          'prompts', () async {
        expect(
          await open(_Device.denied).lastKnownFix(),
          const Err<LocationFix?, LocationFailure>(
            LocationFailure.permissionDenied(),
          ),
        );
      });

      test('a fix keeps its time, accuracy and mock flag', () async {
        final device = open(_Device.located);
        expect(
          await device.currentFix(),
          Ok<LocationFix, LocationFailure>(_fix),
        );
        expect(
          await device.lastKnownFix(),
          Ok<LocationFix?, LocationFailure>(_fix),
        );
      });

      test('a timeout fails with LOC_UNAVAILABLE', () async {
        expect(
          await open(_Device.timesOut).currentFix(),
          const Err<LocationFix, LocationFailure>(
            LocationFailure.unavailable('fix timed out'),
          ),
        );
      });

      test('no cached fix is Ok(null)', () async {
        expect(
          await open(_Device.noCache).lastKnownFix(),
          const Ok<LocationFix?, LocationFailure>(null),
        );
      });
    });
  }

  test('ADR-014 the adapter asks for approximate accuracy with a time '
      'limit', () async {
    final platform = _ScriptedPlatform(_Device.located);
    await GeolocatorDeviceLocator(platform).currentFix();
    expect(platform.settings?.accuracy, LocationAccuracy.low);
    expect(platform.settings?.timeLimit, GeolocatorDeviceLocator.fixTimeLimit);
  });

  test('ADR-014 on Android the adapter reads LocationManager, never Google '
      'Play services', () async {
    final platform = _ScriptedPlatform(_Device.located);
    await GeolocatorDeviceLocator(
      platform,
      androidLocationManager: true,
    ).currentFix();
    final settings = platform.settings;
    expect(settings, isA<AndroidSettings>());
    expect(settings is AndroidSettings && settings.forceLocationManager, true);
    expect(settings?.accuracy, LocationAccuracy.low);
  });
}
