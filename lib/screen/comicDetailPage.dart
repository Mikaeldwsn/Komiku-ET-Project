import 'package:flutter/material.dart';
import 'package:komiku/class/Comic.dart';
import 'package:komiku/class/ComicDetail.dart';
import 'package:komiku/screen/readComic.dart';
import 'package:komiku/services/api_services.dart';

class ComicDetailPage extends StatefulWidget {
  final Comic comic;
  const ComicDetailPage({super.key, required this.comic});

  @override
  State<ComicDetailPage> createState() => _ComicDetailPageState();
}

class _ComicDetailPageState extends State<ComicDetailPage> {
  late Comic comic;
  late ComicDetail? details;
  
  bool isLoading = true;
  @override 
  void initState() {
    super.initState();
    comic = widget.comic;
    loadDetail();
  }
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(comic.title),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Poster
                Image.network(
                  "https://ubaya.cloud/flutter/160423007/komiku/${comic.posterUrl}",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        comic.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "By ${comic.creator.username}",
                        style: const TextStyle(fontSize: 18),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(details!.rating.toString()),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        children: details!.categories
                            .map(
                              (e) => Chip(label: Text(e)),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "${comic.viewCount} views",
                      ),

                      const SizedBox(height: 24),

                      /// Read Comic Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadComicPage(
                                  comicId: comic.id,
                                  comicTitle: comic.title,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.menu_book),
                          label: const Text(
                            'Baca Komik',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
  );
}

  Future<void> loadDetail() async{
    details = await ApiService.getComicDetail(comic.id);
    setState(() {
      isLoading = false;
    });
  }
}