
class ComicDetail {
  double rating;
  List<String> categories;
  ComicDetail({required this.rating, required this.categories});

  factory ComicDetail.fromJson(Map<String, dynamic> json) {
    return ComicDetail(
      rating: double.parse(json['rating'].toString()),
      categories: json['categories'].toString().split(','),
    );
  }

}