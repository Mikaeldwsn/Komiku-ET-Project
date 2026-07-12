
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
    appBar: AppBar(
      title: const Text("Category"),
    ),
    body: isLoading ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,      
              runSpacing: 8,   
              children: categories.map((category) {
                return ActionChip(
                  label: Text(category.name),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComicPage(
                            categoryId: category.id,
                          ),
                        ),
                      );
                    
                  },
                );
              }).toList(),
            ),
          )
  );
}

  void loadCategory() async{
    categories = await ApiService.GetAllCategory();

    setState(() {
      isLoading = false;
    });
  }
}