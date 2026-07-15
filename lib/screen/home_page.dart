import 'package:flutter/material.dart';
import 'package:komiku/main.dart';
import 'package:komiku/screen/comicPage.dart'; 
import 'createComic.dart'; 
import 'categoryPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CategoryPage(),
    ComicPage(),
    CreateComicPage(),
  ];

  final List<String> _titles = const [
    "Kategori",
    "Cari Komik",
    "Buat Komik",
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.orange[900],
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
              accountName: Text(
                activeUsername.isNotEmpty ? activeUsername : 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              accountEmail: const Text(''),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kategori'),
              selected: _selectedIndex == 0,
              selectedColor: Colors.orange[900],
              onTap: () {
                _onTabTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Cari'),
              selected: _selectedIndex == 1,
              selectedColor: Colors.orange[900],
              onTap: () {
                _onTabTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_box),
              title: const Text('Buat Komik'),
              selected: _selectedIndex == 2,
              selectedColor: Colors.orange[900],
              onTap: () {
                _onTabTapped(2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);r
                doLogout();
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange[900],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Buat Komik',
          ),
        ],
      ),
    );
  }
}