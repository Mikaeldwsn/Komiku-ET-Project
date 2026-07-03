import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Ganti dengan NRP Anda
const String baseUrl = "https://ubaya.cloud/flutter/160423007/komiku";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorLogin = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController.text = "";
    _passwordController.text = "";
    _errorLogin = "";
  }

  void doLogin() async {
    setState(() {
      _isLoading = true;
      _errorLogin = "";
    });

    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      body: {
        'username': _usernameController.text,
        'password': _passwordController.text,
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);

      if (json['result'] == 'success') {
        //simpan session di shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("user_id", json['user_id'].toString());
        prefs.setString("username", json['username']);

        // Redirect ke Halaman Kategori
        // SESUAIKAN nama widget CategoryPage
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const CategoryPagePlaceholder()),
        );
      } else {
        setState(() {
          _errorLogin = json['message'] ?? "Username atau password salah";
        });
      }
    } else {
      setState(() {
        _errorLogin = "Gagal terhubung ke server";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 1),
          color: Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 5)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username',
                  hintText: 'Masukkan username Anda',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                ),
              ),
            ),
            if (_errorLogin.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  _errorLogin,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 50,
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : doLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 25),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder sementara - ganti dengan widget Halaman Kategori
class CategoryPagePlaceholder extends StatelessWidget {
  const CategoryPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kategori')),
      body: const Center(child: Text('Halaman Kategori')),
    );
  }
}