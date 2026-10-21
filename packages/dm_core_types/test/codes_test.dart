import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

/// Reads the backticked code list that follows [label] in DESIGN.md
/// Appendix J, so the enums cannot drift from the normative text.
List<String> _appendixJCodes(String label) {
  final design = File('../../DESIGN.md').readAsStringSync();
  final appendix = design
      .split('## Appendix J')[1]
      .split('## Appendix K')
      .first;
  final match = RegExp('$label: `([^`]+)`').firstMatch(appendix);
  return (match?.group(1) ?? '').split(', ');
}

void main() {
  group('FailureCode (REQ-ERR-002)', () {
    test('lists exactly the Appendix J failure codes in order '
        '(REQ-ERR-002)', () {
      expect(
        FailureCode.values.map((c) => c.wire).toList(),
        _appendixJCodes('Failures'),
      );
    });

    test('fromWire round-trips every code and rejects unknown names '
        '(REQ-ERR-002)', () {
      for (final code in FailureCode.values) {
        expect(FailureCode.fromWire(code.wire), code);
      }
      expect(FailureCode.fromWire('NOT_A_CODE'), isNull);
    });
  });

  group('EventCode (REQ-ERR-002)', () {
    test('lists exactly the Appendix J event-log codes in order '
        '(REQ-ERR-002)', () {
      expect(
        EventCode.values.map((c) => c.wire).toList(),
        _appendixJCodes('Event-log codes'),
      );
    });

    test('fromWire round-trips every code and rejects unknown names '
        '(REQ-ERR-002)', () {
      for (final code in EventCode.values) {
        expect(EventCode.fromWire(code.wire), code);
      }
      expect(EventCode.fromWire('app_start'), isNull);
    });
  });
}
