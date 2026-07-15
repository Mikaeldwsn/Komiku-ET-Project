import 'package:flutter/material.dart';
import 'package:komiku/class/Comic.dart';
import 'package:komiku/screen/comicDetailPage.dart';
import 'package:komiku/services/api_services.dart';

class ComicPage extends StatefulWidget {
  final int? categoryId;

  const ComicPage({super.key,this.categoryId,});

  @override
  State<ComicPage> createState() => _ComicPageState();
}

class _ComicPageState extends State<ComicPage> {
  List<Comic> comics = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComic();
  }

  Future<void> loadComic() async {
    if (widget.categoryId == null) {
      comics = await ApiService.getComicAllComic();
    } else {
      comics = await ApiService.getComicByCategory(widget.categoryId!);
    }

    setState(() {
      isLoading = false;
    });

    _fetchMissingCategories();
  }

  Future<void> searchComic(String keyword) async{
    comics = await ApiService.searchComic(keyword: keyword, categoryId: widget.categoryId);

    setState(() {
      isLoading = false;
    });

    _fetchMissingCategories();
  }

  void _fetchMissingCategories() {
    for (var comic in comics) {
      if (comic.categories.isEmpty) {
        ApiService.getComicDetail(comic.id).then((detail) {
          if (mounted) {
            setState(() {
              comic.categories = detail.categories;
            });
          }
        }).catchError((e) {          
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.categoryId == null
          ? null
          : AppBar(
              title: const Text("Category Comics"),
            ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (String value){
              setState((){
                isLoading = true;
                if (value.isEmpty){
                  loadComic();
                }
                else{
                  searchComic(value);
                }
              });
            },
            decoration: InputDecoration(
              hintText: "Search comics...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        Expanded(
          child: isLoading ? const Center(child: CircularProgressIndicator())
          :comics.isEmpty? const Center(
              child: Text(
                "Comic tidak ditemukan",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : 
          ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: comics.length,
              itemBuilder: (context, index) {
                final comic = comics[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComicDetailPage(
                            comic: comic,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [

                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: comic.posterUrl.isNotEmpty
                                ? Image.network(
                                    "https://ubaya.cloud/flutter/160423007/komiku/${comic.posterUrl}",
                                    width: 80,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 120,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.image),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 80,
                                    height: 120,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image),
                                  ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comic.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 18),
                                    const SizedBox(width: 6),
                                    Text(comic.creator.username),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(Icons.visibility, size: 18),
                                    const SizedBox(width: 6),
                                    Text("${comic.viewCount} views"),
                                  ],
                                ),

                                if (comic.categories.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    children: comic.categories
                                        .map((cat) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: Colors.orange.shade200),
                                              ),
                                              child: Text(
                                                cat,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.orange.shade900,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
                
        )
        
      ],
    )

      
    );
  }
}