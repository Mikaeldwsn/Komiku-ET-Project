

class ComicCategory {
  int id;
  String name;
  ComicCategory({required this.id, required this.name});

  factory ComicCategory.fromJson(Map<String, dynamic> json) {
    return ComicCategory(
      id: int.parse(json['id'].toString()),
      name: json['name'],
    );
  }
}
