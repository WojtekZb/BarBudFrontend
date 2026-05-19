import 'package:flutter/material.dart';

import 'pages/startup.dart';

void main() {
  runApp(const BarBudApp());
}

class BarBudApp extends StatelessWidget {
  const BarBudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartupPage(),
    );
  }
}