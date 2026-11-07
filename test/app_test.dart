import 'package:comprimage/app.dart';
import 'package:comprimage/services/locale_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows English by default', (tester) async {
    await tester.pumpWidget(
      ComprimageApp(localeController: LocaleController()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Select photos'), findsOneWidget);
  });

  testWidgets('follows German system locale', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('de', 'DE')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      ComprimageApp(localeController: LocaleController()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fotos auswählen'), findsOneWidget);
  });

  testWidgets('unsupported locale falls back to English', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(
      ComprimageApp(localeController: LocaleController()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Select photos'), findsOneWidget);
  });

  testWidgets('language switch persists', (tester) async {
    final c = LocaleController();
    await tester.pumpWidget(ComprimageApp(localeController: c));
    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(find.text('Fotos auswählen'), findsOneWidget);
    final c2 = LocaleController();
    await c2.load();
    expect(c2.locale, const Locale('de'));
  });
}
