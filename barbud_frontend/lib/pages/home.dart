import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const storage = FlutterSecureStorage();

  String? username;

  @override
  void initState() {
    super.initState();
    loadUsername();
  }

  Future<void> loadUsername() async {
    final storedUsername = await storage.read(key: 'username');

    setState(() {
      username = storedUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Text(
            "Welcome ${username ?? 'user'}",
            style: const TextStyle(
              fontSize: 28,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}