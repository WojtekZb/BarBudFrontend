import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://145.220.72.160:8080";
  static const FlutterSecureStorage storage = FlutterSecureStorage();

 static Future<void> save(
    Map<String, dynamic> where,
    String saving,
    String keepAs,
  ) async {
    final value = where[saving];

    if (value != null) {
      await storage.write(
        key: keepAs,
        value: value.toString(),
      );
    }
  }

  static Future<String?> getUserId() async {
    return await storage.read(key: "id");
  }

  static Future<void> debugStorage() async {
    print("----- STORAGE DEBUG -----");
    print("id: ${await storage.read(key: "id")}");
    print("userId: ${await storage.read(key: "userId")}");
    print("username: ${await storage.read(key: "username")}");
    print("accessToken: ${await storage.read(key: "accessToken")}");
    print("refreshToken: ${await storage.read(key: "refreshToken")}");
    print("-------------------------");
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
        throw Exception("Empty response from server.");
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      await save(data, "userId", "id");
      await save(data, "username", "username");
      await save(data, "accessToken", "accessToken");
      await save(data, "accessExpiresIn", "accessExpiresIn");
      await save(data, "refreshToken", "refreshToken");
      await save(data, "refreshExpiresIn", "refreshExpiresIn");

      print("CHECK SAVED ID:");
      print(await storage.read(key: "id"));

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

      await save(data, "userId", "id");
      await save(data, "username", "username");
      await save(data, "accessToken", "accessToken");
      await save(data, "accessExpiresIn", "accessExpiresIn");
      await save(data, "refreshToken", "refreshToken");
      await save(data, "refreshExpiresIn", "refreshExpiresIn");

      print("CHECK SAVED ID:");
      print(await storage.read(key: "id"));

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

      await save(data, "userId", "id");
      await save(data, "username", "username");
      await save(data, "accessToken", "accessToken");
      await save(data, "accessExpiresIn", "accessExpiresIn");
      await save(data, "refreshToken", "refreshToken");
      await save(data, "refreshExpiresIn", "refreshExpiresIn");

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