import 'package:integration_test/integration_test.dart';

import 'package:barbud_frontend/main.dart';

import 'robots/login_robot.dart';
import 'robots/home_robot.dart';
import 'robots/mybar_robot.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> startCleanApp(WidgetTester tester) async {
  const storage = FlutterSecureStorage();
  await storage.deleteAll();

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 500));

  await tester.pumpWidget(const BarBudApp());

  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
}

Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));

    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw Exception('Widget not found after waiting: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user can login and open My Bars page and see bar details', (tester) async {
    await startCleanApp(tester);
    await waitForWidget(
      tester,
      find.byKey(const Key('emailField')),
    );

    final loginRobot = LoginRobot(tester);
    final homeRobot = HomeRobot(tester);
    final myBarRobot = MyBarRobot(tester);

    await loginRobot.loginWith(
      'admin@example.com',
      'BorekILolek1!',
    );

    await homeRobot.expectHomePageVisible();

    await homeRobot.tapMyBarsButton();

    await myBarRobot.expectMyBarPageVisible();

    await myBarRobot.tapBarDetailsCard(0);
  });

  testWidgets('user sees error when login credentials are incorrect', (tester) async {
    await startCleanApp(tester);
    await waitForWidget(
      tester,
      find.byKey(const Key('emailField')),
    );

    final loginRobot = LoginRobot(tester);

    await loginRobot.loginWith(
      'wrong@example.com',
      'wrongpassword',
    );

    await loginRobot.expectLoginErrorVisible();
  });

  testWidgets('user loggs in and loggs out', (tester) async {
    await startCleanApp(tester);

    await waitForWidget(
      tester,
      find.byKey(const Key('emailField')),
    );

    final loginRobot = LoginRobot(tester);
    final homeRobot = HomeRobot(tester);

    await loginRobot.loginWith(
      'admin@example.com',
      'BorekILolek1!',
    );

    await homeRobot.expectHomePageVisible();
    await homeRobot.tapProfileButton();
    await homeRobot.tapLogoutButton();
  });
}