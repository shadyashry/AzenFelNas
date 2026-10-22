import 'package:daily_muslim/features/contexts/domain/gazetteer_place.dart';
import 'package:dm_civil_time/dm_civil_time.dart';

/// A few places shaped like the pinned payload (§15 D72).
final List<GazetteerPlace> samplePlaces = [
  GazetteerPlace(
    id: 360630,
    name: 'Cairo',
    asciiName: 'Cairo',
    arabicNames: const ['القاهرة', 'قاهره'],
    englishNames: const ['El Cairo', 'Kairo', 'Le Caire'],
    country: 'EG',
    admin1: '11',
    point: GeoPointE6(30062630, 31249670),
    population: 9606916,
    zoneId: 'Africa/Cairo',
  ),
  GazetteerPlace(
    id: 360631,
    name: 'Cairo Montenotte',
    asciiName: 'Cairo Montenotte',
    arabicNames: const [],
    englishNames: const [],
    country: 'IT',
    admin1: '08',
    point: GeoPointE6(44398000, 8276000),
    population: 13000,
    zoneId: 'Europe/Rome',
  ),
  GazetteerPlace(
    id: 2657896,
    name: 'Zürich',
    asciiName: 'Zurich',
    arabicNames: const ['زيورخ'],
    englishNames: const ['Zurich'],
    country: 'CH',
    admin1: 'ZH',
    point: GeoPointE6(47366670, 8550000),
    population: 341730,
    zoneId: 'Europe/Zurich',
  ),
  GazetteerPlace(
    id: 104515,
    name: 'Mecca',
    asciiName: 'Mecca',
    arabicNames: const ['مكة المكرمة', 'مكّة'],
    englishNames: const ['Makkah'],
    country: 'SA',
    admin1: '14',
    point: GeoPointE6(21426670, 39826110),
    population: 1323624,
    zoneId: 'Asia/Riyadh',
  ),
];
