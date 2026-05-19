import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/ingredient.dart';

class BarService {
  static const String baseUrl = "http://145.220.72.160:8080";

    static Future<List<BarIngredient>> getAllIngredients() async {
    final url = Uri.parse("$baseUrl/bar/ingredients");

    final response = await http.get(url);

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
}