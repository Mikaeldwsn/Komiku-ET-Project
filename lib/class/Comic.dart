
import 'User.dart';
class Comic{
  int id;
  String title;
  String posterUrl;
  User creator;
  int viewCount;
  List<String> categories;

  Comic({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.creator,
    required this.viewCount,
    required this.categories,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    List<String> cats = [];
    if (json['categories'] != null && json['categories'].toString().isNotEmpty) {
      cats = json['categories'].toString().split(',');
    }
    return Comic(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      posterUrl: json['poster_url'],
      creator: User.fromJson(json['creator']),
      viewCount: int.parse(json['view_count'].toString()),
      categories: cats,
    );
  }
}