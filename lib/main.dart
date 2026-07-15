import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/login.dart';
import '/utils/session_helper.dart';
import 'screen/home_page.dart';

// global variable
String activeUserId = "";
String activeUsername = "";

Future<String> checkUser() async {
  final prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString("user_id") ?? '';
  activeUsername = prefs.getString("username") ?? '';
  return userId;
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkUser().then((String result) {
    if (result == '') {
      runApp(const MaterialAppWrapper(home: LoginPage()));
    } else {
      activeUserId = result;
      runApp(const MaterialAppWrapper(home: HomePage()));
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
  main();
}