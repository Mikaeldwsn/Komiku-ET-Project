import 'package:komiku/class/User.dart';

class Rating {
  int id;
  User user;
  int ratingValue;
  String date;

  Rating({required this.id,required this.user, required this.ratingValue, required this.date});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: int.parse(json['id'].toString()),
      user: User.fromJson(json['user']),
      ratingValue: int.parse(json['rating_calue'].toString()),
      date: json['created_at'].toString(),
    );
  }
}