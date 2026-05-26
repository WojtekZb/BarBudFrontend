import 'package:flutter/material.dart';

import 'pages/startup.dart';
import 'pages/auth.dart';
import 'pages/home.dart';

void main() {
  runApp(const BarBudApp());
}

class BarBudApp extends StatelessWidget {
  const BarBudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: const StartupPage(),

      routes: {
        "/auth": (context) => const AuthPage(),
        "/home": (context) => HomePage(),
      },
    );
  }
}