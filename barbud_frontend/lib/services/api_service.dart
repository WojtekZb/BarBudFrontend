import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://localhost:8080";

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return {
          "message": "Oops something went wrong. Please try again.",
        };
      }

      return jsonDecode(response.body);
    }

    throw Exception("Register failed: ${response.statusCode} ${response.body}");
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Login failed: ${response.statusCode} ${response.body}");
  }

  static Future<Map<String, dynamic>> refresh({
    required String refreshToken,
  }) async {
    final url = Uri.parse("$baseUrl/auth/refresh");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "refreshToken": refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Refresh failed: ${response.statusCode} ${response.body}");
  }
}