
import 'User.dart';
class Comic{
  int id;
  String title;
  String posterUrl;
  User creator;
  int viewCount;

  Comic({required this.id,required this.title,required this.posterUrl,required this.creator,required this.viewCount});

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: int.parse(json['id'].toString()),
      title: json['title'],
      posterUrl: json['poster_url'],
      creator: User.fromJson(json['creator']),
      viewCount: int.parse(json['view_count'].toString()),
    );
  }
}