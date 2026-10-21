import 'package:dm_lints/dm_lints.dart';
import 'package:test/test.dart';

import 'fake_repo.dart';

// IDs are assembled at runtime so this file never contains a literal
// unknown ID that the repository-level REQ index check would report.
const _area = 'ZZZ';
const _unknownId = 'REQ-$_area-999';
const _outsideArea = 'NOT';
const _outsideId = 'REQ-$_outsideArea-001';

const _design =
    '''
# DESIGN

See REQ-DOM-001..005 in prose; ranges outside Appendix F are not checked.

## Appendix F — Requirement index

**Domain**
- `REQ-DOM-001` Displayed instants are ordered.
- `REQ-DOM-002` Every origin is typed.

## Appendix G — Next
- `$_outsideId` Not a definition: outside Appendix F.
''';

List<Finding> _check(FakeRepo repo) =>
    const ReqIndexChecker().check(repo.root).findings;

void main() {
  group('REQ index (DESIGN.md §0.1 item 3)', () {
    test('IDs defined in Appendix F pass', () {
      final repo = FakeRepo()
        ..write('DESIGN.md', _design)
        ..write('a/test.dart', "test('ordering (REQ-DOM-001)', () {});\n")
        ..write('b/notes.md', 'Covers REQ-DOM-002.\n');

      expect(_check(repo), isEmpty);
    });

    test('an unknown ID is reported with its file and line', () {
      final repo = FakeRepo()
        ..write('DESIGN.md', _design)
        ..write('lib/x.dart', '// fine\n// cites $_unknownId\n');

      final finding = _check(repo).single;

      expect(finding.rule, 'req-unknown');
      expect(finding.path, 'lib/x.dart');
      expect(finding.line, 2);
      expect(finding.message, contains(_unknownId));
    });

    test('an ID defined only outside Appendix F is unknown', () {
      final repo = FakeRepo()
        ..write('DESIGN.md', _design)
        ..write('x.py', '# $_outsideId\n');

      expect(_check(repo).single.rule, 'req-unknown');
    });

    test('ignored directories and unscanned extensions are skipped', () {
      final repo = FakeRepo()
        ..write('DESIGN.md', _design)
        ..write('.dart_tool/x.dart', '// $_unknownId\n')
        ..write('build/x.json', '"$_unknownId"\n')
        ..write('notes.txt', '$_unknownId\n');

      expect(_check(repo), isEmpty);
    });

    test('an ID defined twice in Appendix F is reported', () {
      final repo = FakeRepo()
        ..write(
          'DESIGN.md',
          '## Appendix F\n- `REQ-DOM-001` a.\n- `REQ-DOM-001` b.\n',
        );

      final finding = _check(repo).single;

      expect(finding.rule, 'req-duplicate');
      expect(finding.line, 3);
    });

    test('a missing DESIGN.md or Appendix F is reported', () {
      expect(_check(FakeRepo()).single.rule, 'req-design-missing');

      final noAppendix = FakeRepo()..write('DESIGN.md', '# DESIGN\n');
      expect(_check(noAppendix).single.rule, 'req-appendix-missing');
    });
  });
}
