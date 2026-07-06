import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/login.dart';
import '/utils/session_helper.dart';

//variabel global username
String activeUserId = "";
String activeUsername = "";

// checkUser dipanggil sblm app jalan, untuk cek apakah user sudah pernah login sebelumnya
Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString("user_id") ?? '';
  return userId;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) { //PANGGIL METHOD checkUser()
    if (result == '') {
      // IF blm pernah login THEN tampilkan halaman Login
      runApp(const MaterialAppWrapper(home: LoginPage()));
    } else {
      // IF sdh pernah login THEN langsung masuk
      activeUserId = result;
      runApp(const MaterialAppWrapper(home: CategoryPagePlaceholder()));
    }
  });
}

class MaterialAppWrapper extends StatelessWidget {
  final Widget home;
  const MaterialAppWrapper({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Komiku',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: home,
    );
  }
}

void doLogout() async {
  await SessionHelper.logout();
  main(); // panggil ulang main() supaya kembali ke LoginPage
}