import 'package:flutter/material.dart';
import 'history_page.dart';
import 'new_ficha_page.dart';
import 'profile_page.dart'; // ✅ Importa a nova página de perfil

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late int userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    userId = args['userId'];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HistoryPage(userId: userId),
      NewFichaPage(userId: userId),
      ProfilePage(userId: userId), // ✅ Nova página adicionada
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Nova Ficha',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // ✅ Ícone de perfil
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
