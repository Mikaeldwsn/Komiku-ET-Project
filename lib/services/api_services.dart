import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://ubaya.cloud/flutter/160423007/komiku";

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      body: {"username": username, "password": password},
    );
    return jsonDecode(response.body);
  }
}
