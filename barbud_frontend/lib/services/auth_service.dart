import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://145.220.72.160:8080";
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static void save(Map<String, dynamic> where,String Saving) async {
    if (where[Saving] != null) {
        await storage.write(
          key: Saving,
          value: where[Saving],
        );
      }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
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
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        return {
          "message": "Oops something went wrong. Please try again.",
        };
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      save(data, "id");
      save(data, "username");
      save(data, "accessToken");
      save(data, "accessExpiresIn");
      save(data, "refreshToken");
      save(data, "refreshExpiresIn");

      return data;
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

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      save(data, "id");
      save(data, "username");
      save(data, "accessToken");
      save(data, "accessExpiresIn");
      save(data, "refreshToken");
      save(data, "refreshExpiresIn");

      return data;
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
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      save(data, "id");
      save(data, "username");
      save(data, "accessToken");
      save(data, "accessExpiresIn");
      save(data, "refreshToken");
      save(data, "refreshExpiresIn");

      return data;
    }

    throw Exception("Refresh failed: ${response.statusCode} ${response.body}");
  }

  static Future<bool> tryRefreshOnStartup() async {
    final oldRefreshToken = await storage.read(key: "refreshToken");

    if (oldRefreshToken == null || oldRefreshToken.isEmpty) {
      return false;
    }

    try {
      await refresh(refreshToken: oldRefreshToken);
      return true;
    } catch (e) {
      await logout();
      return false;
    }
  }

  static Future<void> logout() async {
    storage.deleteAll();
  }

}