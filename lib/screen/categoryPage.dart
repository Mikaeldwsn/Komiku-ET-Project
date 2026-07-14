
import 'package:flutter/material.dart';
import 'package:komiku/class/ComicCategory.dart';
import 'package:komiku/screen/comicPage.dart';
import 'package:komiku/services/api_services.dart';

class CategoryPage extends  StatefulWidget{

  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CategoryPage>{

  List<ComicCategory> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategory();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                IconData icon;
                Color color;

                switch (category.name.toLowerCase()) {
                  case 'komedi':
                    icon = Icons.emoji_emotions;
                    color = Colors.amber.shade700;
                    break;
                  case 'action':
                    icon = Icons.bolt;
                    color = Colors.red.shade700;
                    break;
                  case 'horor':
                    icon = Icons.nights_stay;
                    color = Colors.purple.shade700;
                    break;
                  case 'romance':
                    icon = Icons.favorite;
                    color = Colors.pink.shade700;
                    break;
                  case 'fantasy':
                    icon = Icons.auto_awesome;
                    color = Colors.blue.shade700;
                    break;
                  case 'drama':
                    icon = Icons.theater_comedy;
                    color = Colors.teal.shade700;
                    break;
                  default:
                    icon = Icons.category;
                    color = Colors.orange.shade700;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComicPage(
                            categoryId: category.id,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void loadCategory() async{
    categories = await ApiService.GetAllCategory();

    setState(() {
      isLoading = false;
    });
  }
}