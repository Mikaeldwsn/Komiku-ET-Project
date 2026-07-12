import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const String baseUrl = "https://ubaya.cloud/flutter/160423007/komiku";

class UploadPage extends StatefulWidget {
  final int chapterId;
  const UploadPage({super.key, required this.chapterId}); 

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // Daftar halaman yang sudah berhasil di-upload (untuk ditampilkan sebagai preview)
  final List<Uint8List> _uploadedPages = [];

  int _pageCounter = 0; // dipakai sebagai page_number, mulai dari 1
  bool _isUploading = false;

  // ---------------------------------------------------------
  // Image Picker - bottom sheet (persis pola Week 12)
  // ---------------------------------------------------------
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
                    Navigator.of(context).pop();
                    _pickAndUpload(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Kamera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUpload(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // Ambil gambar lalu langsung upload ke server (pola Week 12:
  // setiap gambar dipilih langsung dikirim, bukan ditumpuk dulu)
  // ---------------------------------------------------------
  Future<void> _pickAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 60,
      maxHeight: 1600,
      maxWidth: 1200,
    );

    if (image == null) return;

    final bytes = await image.readAsBytes();

    setState(() {
      _isUploading = true;
    });

    _pageCounter += 1;
    final String base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse("$baseUrl/upload_page.php"),
      body: {
        'chapter_id': widget.chapterId.toString(),
        'page_number': _pageCounter.toString(),
        'image': base64Image,
      },
    );

    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          _uploadedPages.add(bytes);
        });
      } else {
        _pageCounter -= 1; // rollback nomor halaman kalau gagal
        _showMessage('Gagal upload halaman: ${json['message'] ?? ''}');
      }
    } else {
      _pageCounter -= 1;
      _showMessage('Gagal terhubung ke server');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selesai() {
    if (_uploadedPages.isEmpty) {
      _showMessage('Upload minimal 1 halaman sebelum selesai');
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    _showMessage('Komik berhasil dibuat!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Halaman Komik')),
      body: Column(
        children: [
          Expanded(
            child: _uploadedPages.isEmpty
                ? const Center(child: Text('Belum ada halaman diupload'))
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _uploadedPages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Image.memory(
                              _uploadedPages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              color: Colors.black54,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : () => _showPicker(context),
                    icon: _isUploading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.add_photo_alternate),
                    label: Text(_isUploading ? 'Mengupload...' : 'Tambah Halaman'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _isUploading ? null : _selesai,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Selesai', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}