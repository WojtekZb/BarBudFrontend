import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class LoginRobot {
  final WidgetTester tester;

  LoginRobot(this.tester);

  Future<void> enterEmail(String email) async {
    final emailField = find.byKey(const Key('emailField'));

    expect(emailField, findsOneWidget);

    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();
  }

  Future<void> enterPassword(String password) async {
    final passwordField = find.byKey(const Key('passwordField'));

    expect(passwordField, findsOneWidget);

    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
  }

  Future<void> tapLoginButton() async {
    final loginButton = find.byKey(const Key('loginButton'));

    expect(loginButton, findsOneWidget);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  Future<void> loginWith(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapLoginButton();
  }

  Future<void> expectLoginErrorVisible() async {
  await tester.pump(const Duration(seconds: 1));

  expect(find.byKey(const Key('loginErrorMessage')), findsOneWidget);
}

  void expectLoginButtonVisible() {
    expect(find.byKey(const Key('loginButton')), findsOneWidget);
  }
}