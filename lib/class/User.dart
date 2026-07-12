class User {
  int id;
  String username;
  String email;
  String password;

  User({required this.id, required this.username, required this.email, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()), 
      username: json['username'], 
      email: json['email'], 
      password: "",
    );
  }

}
