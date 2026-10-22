import 'package:daily_muslim/app/bootstrap.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await Bootstrap.run());
}
