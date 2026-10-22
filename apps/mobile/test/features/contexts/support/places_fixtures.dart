import 'package:daily_muslim/features/contexts/domain/context_place.dart';
import 'package:dm_civil_time/dm_civil_time.dart';

/// Cairo, as a current fix would place it.
final cairoPlace = ContextPlace(
  point: GeoPointE6(30044420, 31235712),
  horizontalAccuracyM: 1200,
  zoneId: 'Africa/Cairo',
  country: 'EG',
  label: '',
);

/// Makkah, as a manual place.
final makkahPlace = ContextPlace(
  point: GeoPointE6(21422487, 39826206),
  horizontalAccuracyM: null,
  zoneId: 'Asia/Riyadh',
  country: 'SA',
  label: 'مكة',
);

/// London, as a current fix would place it.
final londonPlace = ContextPlace(
  point: GeoPointE6(51507351, -127758),
  horizontalAccuracyM: 800,
  zoneId: 'Europe/London',
  country: 'GB',
  label: '',
);

/// A point in the open ocean: nautical zone, no country.
final oceanPlace = ContextPlace(
  point: GeoPointE6(-30000000, -20000000),
  horizontalAccuracyM: 3000,
  zoneId: 'Etc/GMT+1',
  country: null,
  label: '',
);
