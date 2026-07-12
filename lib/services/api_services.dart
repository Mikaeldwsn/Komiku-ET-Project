import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:komiku/class/Comic.dart';
import 'package:komiku/class/ComicCategory.dart';
import 'package:komiku/class/ComicDetail.dart';

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

  static Future<List<ComicCategory>> GetAllCategory() async{
    final response = await http.post(Uri.parse("$baseUrl/get_categories.php"));
    final json = jsonDecode(response.body);
    List data = json["data"];

    return data
        .map((e) => ComicCategory.fromJson(e))
        .toList();
  }


  // #region Comic
  static Future<List<Comic>> getComicByCategory( int id) async{
    final response = await http.post(
      Uri.parse("$baseUrl/getComicByCategory.php"),
      body: {'category_id' : id.toString()}
      );
    final json = jsonDecode(response.body);
    final List data = json['data'] ?? [];

    return data
        .map((e) => Comic.fromJson(e))
        .toList();
  }
  static Future<List<Comic>> getComicAllComic() async{
    final response = await http.post(
      Uri.parse("$baseUrl/getAllComic.php"),
      );
    final json = jsonDecode(response.body);
    final List data = json['data'] ?? [];

    return data
        .map((e) => Comic.fromJson(e))
        .toList();
  }

  static Future<List<Comic>> searchComic({required String keyword, int? categoryId } ) async{
    final body = {
      'keyword' : keyword,
    };
    if (categoryId != null){
      body['category_id'] = categoryId.toString();
    }

    final response = await http.post(
      Uri.parse("$baseUrl/searchComic.php"),
      body: body,
    );
    final json = jsonDecode(response.body);
    final List data = json['data'] ?? [];

    return data
        .map((e) => Comic.fromJson(e))
        .toList();
  }

  static Future<ComicDetail> getComicDetail(int comicId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/getComicDetail.php"),
      body: {
        'comic_id' : comicId.toString(),
      }
    );
    final json = jsonDecode(response.body);
    return ComicDetail.fromJson(json['data']);
  }


  // #endregion


}
