import 'package:daily_muslim/features/shell/domain/open_system_settings.dart';

/// Records the settings screens asked for.
final class FakeSystemSettings implements OpenSystemSettings {
  /// The screens asked for, in order: `location` or `app`.
  final List<String> opened = [];

  @override
  Future<void> location() async => opened.add('location');

  @override
  Future<void> app() async => opened.add('app');
}
