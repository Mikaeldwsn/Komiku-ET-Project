import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:komiku/screen/ComicManagement/upload_page.dart';

const String baseUrl = "https://ubaya.cloud/flutter/160423007/komiku";

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

class CreateComicPage extends StatefulWidget {
  const CreateComicPage({super.key});

  @override
  State<CreateComicPage> createState() => _CreateComicPageState();
}

class _CreateComicPageState extends State<CreateComicPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  List<ComicCategory> _categories = [];
  final Set<int> _selectedCategoryIds = {};
  Uint8List? _posterBytes;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // get daftar kategori dari server
  Future<void> _loadCategories() async {
    final response = await http.post(Uri.parse("$baseUrl/get_categories.php"));
    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          _categories = List<ComicCategory>.from(
            json['data'].map((c) => ComicCategory.fromJson(c)),
          );
        });
      }
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            color: Colors.white,
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galeri'),
                  onTap: () {
                    _imgGaleri();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera'),
                  onTap: () {
                    _imgKamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _imgGaleri() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxHeight: 800,
      maxWidth: 800,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _posterBytes = bytes;
      });
    }
  }

  Future<void> _imgKamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _posterBytes = bytes;
      });
    }
  }
  Future<void> submit() async {
    setState(() {
      _isSubmitting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("user_id") ?? '';

    final createResponse = await http.post(
      Uri.parse("$baseUrl/create_comic.php"),
      body: {'title': _title, 'user_id': userId},
    );

    if (createResponse.statusCode != 200) {
      _showError('Gagal terhubung ke server');
      return;
    }

    Map createJson = jsonDecode(createResponse.body);
    if (createJson['result'] != 'success') {
      _showError('Gagal membuat komik: ${createJson['message']}');
      return;
    }
    final int comicId = createJson['comic_id'];

    // Simpan kategori yang dipilih
    for (int categoryId in _selectedCategoryIds) {
      await http.post(
        Uri.parse("$baseUrl/add_comic_category.php"),
        body: {'comic_id': comicId.toString(), 'category_id': categoryId.toString()},
      );
    }

    // Upload poster
    if (_posterBytes != null) {
      String base64Image = base64Encode(_posterBytes!);
      await http.post(
        Uri.parse("$baseUrl/upload_poster.php"),
        body: {'comic_id': comicId.toString(), 'image': base64Image},
      );
    }

    final chapterResponse = await http.post(
      Uri.parse("$baseUrl/create_chapter.php"),
      body: {
        'comic_id': comicId.toString(),
        'chapter_number': '1',
        'title': 'Chapter 1',
      },
    );

    Map chapterJson = jsonDecode(chapterResponse.body);
    if (chapterJson['result'] != 'success') {
      _showError('Komik tersimpan, tapi gagal membuat chapter');
      return;
    }
    final int chapterId = chapterJson['chapter_id'];

    setState(() {
      _isSubmitting = false;
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UploadPage(chapterId: chapterId),
      ),
    );
  }

  void _showError(String message) {
    setState(() {
      _isSubmitting = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Judul Komik',
                ),
                onChanged: (value) {
                  _title = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul harus diisi';
                  }
                  return null;
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _categories.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: _categories.map((cat) {
                      return CheckboxListTile(
                        title: Text(cat.name),
                        value: _selectedCategoryIds.contains(cat.id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              _selectedCategoryIds.add(cat.id);
                            } else {
                              _selectedCategoryIds.remove(cat.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Poster Komik', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (_posterBytes != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Image.memory(_posterBytes!, height: 200),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () => _showPicker(context),
                child: Text(_posterBytes == null ? 'Pilih Poster' : 'Ganti Poster'),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        final state = _formKey.currentState;
                        if (state == null || !state.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Harap isian diperbaiki')),
                          );
                        } else if (_selectedCategoryIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pilih minimal 1 kategori')),
                          );
                        } else {
                          submit();
                        }
                      },
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Lanjut: Upload Halaman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}