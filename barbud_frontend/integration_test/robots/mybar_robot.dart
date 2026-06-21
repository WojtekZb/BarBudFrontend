import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyBarRobot {
  final WidgetTester tester;

  MyBarRobot(this.tester);

  Future<void> expectMyBarPageVisible() async {
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('myBarPage')), findsOneWidget);
  }

  Future<void> expectNoBarsMessageVisible() async {
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('noBarsMessage')), findsOneWidget);
  }

  Future<void> tapCreateBarButton() async {
    final createBarButton = find.byKey(const Key('createBarButton'));

    expect(createBarButton, findsOneWidget);

    await tester.tap(createBarButton);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapBarDetailsCard(int barId) async {
  final barCard = find.byKey(Key('barDetailsCard_$barId'));

  expect(barCard, findsOneWidget);

  await tester.tap(barCard);
  await tester.pump(const Duration(seconds: 1));
}
}