import 'package:freezed_annotation/freezed_annotation.dart';

part 'high_latitude_method_document.freezed.dart';

/// Wire form of a `HighLatitudeMethod` (§6.2): `"anglePortion"`,
/// `"middleOfNight"`, `"seventhOfNight"`, `{"nearestLatitude": {"latDeg": …}}`
/// or `{"nearestValidDay": {"maxDays": …}}`. Encode and decode it with
/// [HighLatitudeMethodDocumentConverter]. Holds data only; no method
/// parameter is defined in code (§0.2 rule 1).
@freezed
sealed class HighLatitudeMethodDocument with _$HighLatitudeMethodDocument {
  /// `anglePortion`: α/60 of the night.
  const factory anglePortion() = AnglePortionMethodDocument;

  /// `middleOfNight`.
  const factory middleOfNight() = MiddleOfNightMethodDocument;

  /// `seventhOfNight`.
  const factory seventhOfNight() = SeventhOfNightMethodDocument;

  /// `nearestLatitude`: calculate at [latDeg].
  const factory nearestLatitude({required double latDeg}) =
      NearestLatitudeMethodDocument;

  /// `nearestValidDay`: use the nearest day within [maxDays] that has the
  /// event.
  const factory nearestValidDay({required int maxDays}) =
      NearestValidDayMethodDocument;
}

/// JSON converter for [HighLatitudeMethodDocument]: a bare string for the
/// parameterless methods, a one-key object otherwise.
final class HighLatitudeMethodDocumentConverter
    implements JsonConverter<HighLatitudeMethodDocument, Object?> {
  /// Creates the converter.
  const new();

  @override
  HighLatitudeMethodDocument fromJson(Object? json) => switch (json) {
    'anglePortion' => const HighLatitudeMethodDocument.anglePortion(),
    'middleOfNight' => const HighLatitudeMethodDocument.middleOfNight(),
    'seventhOfNight' => const HighLatitudeMethodDocument.seventhOfNight(),
    {
      'nearestLatitude':
          {'latDeg': final num latDeg} && final Map<Object?, Object?> inner,
    }
        when json.length == 1 && inner.length == 1 =>
      HighLatitudeMethodDocument.nearestLatitude(latDeg: latDeg.toDouble()),
    {
      'nearestValidDay':
          {'maxDays': final int maxDays} && final Map<Object?, Object?> inner,
    }
        when json.length == 1 && inner.length == 1 =>
      HighLatitudeMethodDocument.nearestValidDay(maxDays: maxDays),
    _ => throw FormatException('Not a high-latitude method: $json'),
  };

  @override
  Object toJson(HighLatitudeMethodDocument method) => switch (method) {
    AnglePortionMethodDocument() => 'anglePortion',
    MiddleOfNightMethodDocument() => 'middleOfNight',
    SeventhOfNightMethodDocument() => 'seventhOfNight',
    NearestLatitudeMethodDocument(:final latDeg) => {
      'nearestLatitude': {'latDeg': latDeg},
    },
    NearestValidDayMethodDocument(:final maxDays) => {
      'nearestValidDay': {'maxDays': maxDays},
    },
  };
}
