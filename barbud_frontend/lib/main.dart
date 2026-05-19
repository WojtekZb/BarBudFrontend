import 'package:flutter/material.dart';
import 'package:barbud_frontend/pages/auth.dart';
import 'package:barbud_frontend/pages/home.dart';

void main() {
  runApp(const BarBudApp());
}

class BarBudApp extends StatelessWidget {
  const BarBudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: "/auth",

      routes: {
        "/auth": (context) => const AuthPage(),
        "/home": (context) => HomePage(),
      },
    );
  }
}