import 'package:flutter/material.dart';
// Questi due import dicono al Drawer dove trovare le pagine
import 'package:task_list/pages/home_page/home_page.dart';
import 'package:task_list/pages/note_page/note_page.dart'; // Serve per NotePage

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomLeft,
            child: const Text(
              'Menu Impostazioni',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // 1. Chiude il drawer
              Navigator.pop(context);
              // 2. Torna alla Home (MyHomePage)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('Note'),
            onTap: () {
              // 1. Chiude il drawer
              Navigator.pop(context);
              // 2. Va alla NotePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const NotePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}