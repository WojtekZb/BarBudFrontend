import 'dart:convert';

import 'package:barbud_frontend/models/barDetails.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/ingredient.dart';
import '../models/bar.dart';

class BarService {
  static const String baseUrl = "http://localhost:8080";

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final accessToken = await storage.read(key: "accessToken");

    return {
      "Content-Type": "application/json",
      if (accessToken != null && accessToken.isNotEmpty)
        "Authorization": "Bearer $accessToken",
    };
  }

  static Future<List<BarIngredient>> getAllIngredients() async {
    final url = Uri.parse("$baseUrl/bar/ingredients");

    final response = await http.get(
      url,
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => BarIngredient.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception(
      "Failed to load ingredients: ${response.statusCode} ${response.body}",
    );
  }

  static Future<List<UserBar>> getMyBars({
    required int userId,
  }) async {
    final url = Uri.parse("$baseUrl/bar/my-bars");

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        "userId": userId,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => UserBar.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 204 || response.statusCode == 404) {
      return [];
    }

    throw Exception(
      "Failed to load bars: ${response.statusCode} ${response.body}",
    );
  }

  static Future<void> createBar({
    required String name,
    required List<int> ingredientIds,
  }) async {
    final url = Uri.parse("$baseUrl/bar/create");

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        "name": name,
        "ingredientIds": ingredientIds,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception(
      "Failed to create bar: ${response.statusCode} ${response.body}",
    );
  }

  static Future<BarDetails> getBarDetails({
    required int userId,
    required int barId,
  }) async {
    final url = Uri.parse("$baseUrl/bar/details");

    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode({
        "userId": userId,
        "barId": barId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BarDetails.fromJson(data);
    }

    throw Exception("Failed to load bar details: ${response.body}");
  }
}