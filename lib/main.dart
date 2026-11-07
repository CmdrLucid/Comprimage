import 'package:flutter/material.dart';

import 'app.dart';
import 'services/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = LocaleController();
  await localeController.load();
  runApp(ComprimageApp(localeController: localeController));
}
