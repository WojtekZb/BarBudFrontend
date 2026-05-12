import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "HomePage works",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ApiService.register(
                      email: "test@mail.com",
                      password: "Password123!",
                    );

                    print("REGISTER OK:");
                    print(result);
                  } catch (e) {
                    print("REGISTER ERROR:");
                    print(e);
                  }
                },
                child: const Text("Test Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}