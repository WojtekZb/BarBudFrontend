import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  final WidgetTester tester;

  HomeRobot(this.tester);

  Future<void> expectHomePageVisible() async {
    final homePage = find.byKey(const Key('homePage'));

    final end = DateTime.now().add(const Duration(seconds: 10));

    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 250));

      if (homePage.evaluate().isNotEmpty) {
        expect(homePage, findsOneWidget);
        return;
      }
    }

    debugDumpApp();
    throw Exception('HomePage was not found after login.');
  }

  Future<void> tapMyBarsButton() async {
    final myBarsButton = find.byKey(const Key('myBarsButton'));

    expect(myBarsButton, findsOneWidget);

    await tester.tap(myBarsButton);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapProfileButton() async {
    final profileButton = find.byKey(const Key('profileButton'));

    expect(profileButton, findsOneWidget);

    await tester.tap(profileButton);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapLogoutButton() async {
    final logoutButton = find.byKey(const Key('logoutButton'));

    expect(logoutButton, findsOneWidget);

    await tester.tap(logoutButton);
    await tester.pump(const Duration(seconds: 1));
  }
}