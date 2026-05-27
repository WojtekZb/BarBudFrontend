import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/startup.dart';
import 'pages/auth.dart';
import 'pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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