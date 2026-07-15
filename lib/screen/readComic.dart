import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "https://ubaya.cloud/flutter/160423007/komiku";

class ComicComment {
  int id;
  int userId;
  String username;
  String commentText;
  int? parentCommentId;
  String createdAt;

  ComicComment({
    required this.id,
    required this.userId,
    required this.username,
    required this.commentText,
    required this.parentCommentId,
    required this.createdAt,
  });

  factory ComicComment.fromJson(Map<String, dynamic> json) {
    return ComicComment(
      id: int.parse(json['id'].toString()),
      userId: int.parse(json['user_id'].toString()),
      username: json['username'],
      commentText: json['comment_text'],
      parentCommentId: json['parent_comment_id'] == null
          ? null
          : int.parse(json['parent_comment_id'].toString()),
      createdAt: json['created_at'].toString(),
    );
  }
}

class ReadComicPage extends StatefulWidget {
  final int comicId;
  final String comicTitle;

  const ReadComicPage({
    super.key,
    required this.comicId,
    required this.comicTitle,
  });

  @override
  State<ReadComicPage> createState() => _ReadComicPageState();
}

class _ReadComicPageState extends State<ReadComicPage> {
  List<String> _pageUrls = [];
  List<ComicComment> _comments = [];

  bool _isLoadingPages = true;
  bool _isLoadingComments = true;

  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  ComicComment? _replyTarget;

  String? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString("user_id");

    await _loadPages();
    await _loadComments();
    _incrementView();
  }

  Future<void> _loadPages() async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_comic_pages.php"),
      body: {'comic_id': widget.comicId.toString()},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          _pageUrls = List<String>.from(
            json['data'].map((p) => "$baseUrl/${p['image_url']}"),
          );
          _isLoadingPages = false;
        });
      }
    }
  }

  Future<void> _incrementView() async {
    await http.post(
      Uri.parse("$baseUrl/increment_view.php"),
      body: {'comic_id': widget.comicId.toString()},
    );
  }

  Future<void> _loadComments() async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_comments.php"),
      body: {'comic_id': widget.comicId.toString()},
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        setState(() {
          _comments = List<ComicComment>.from(
            json['data'].map((c) => ComicComment.fromJson(c)),
          );
          _isLoadingComments = false;
        });
      }
    }
  }

  Future<void> _submitRating(int value) async {
    if (_userId == null) {
      _showMessage('Anda harus login untuk memberi rating');
      return;
    }

    setState(() {
      _selectedRating = value;
    });

    final response = await http.post(
      Uri.parse("$baseUrl/add_rating.php"),
      body: {
        'comic_id': widget.comicId.toString(),
        'user_id': _userId!,
        'rating_value': value.toString(),
      },
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        _showMessage('Rating tersimpan (rata-rata: ${json['average_rating']})');
      }
    }
  }

  Future<void> _submitComment() async {
    if (_userId == null) {
      _showMessage('Anda harus login untuk berkomentar');
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      _showMessage('Komentar tidak boleh kosong');
      return;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/add_comment.php"),
      body: {
        'comic_id': widget.comicId.toString(),
        'user_id': _userId!,
        'comment_text': _commentController.text.trim(),
        'parent_comment_id': _replyTarget?.id.toString() ?? '',
      },
    );

    if (response.statusCode == 200) {
      Map json = jsonDecode(response.body);
      if (json['result'] == 'success') {
        _commentController.clear();
        setState(() {
          _replyTarget = null;
        });
        _loadComments(); 
      } else {
        _showMessage('Gagal mengirim komentar');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.comicTitle)),
      body: _isLoadingPages
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ..._pageUrls.map((url) {
                  return Image.network(
                    url,
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      );
                    },
                  );
                }),

                const Divider(thickness: 2),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Beri Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          return IconButton(
                            icon: Icon(
                              starValue <= _selectedRating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () => _submitRating(starValue),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Komentar (${_comments.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 8),

                _isLoadingComments
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _comments.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('Belum ada komentar'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _comments.map((comment) {
                              final bool isReply = comment.parentCommentId != null;
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: isReply ? 40 : 16,
                                  right: 16,
                                  bottom: 8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.username,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(comment.commentText),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _replyTarget = comment;
                                        });
                                      },
                                      child: const Text('Balas', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_replyTarget != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Membalas ${_replyTarget!.username}',
                                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _replyTarget = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Tulis komentar...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _submitComment,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}