import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Importiamo il pacchetto

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  // Funzione per aprire il link
  Future<void> _apriSito() async {
    // 1. Definisci l'indirizzo (Cambialo con quello che vuoi)
    final Uri url = Uri.parse('https://flutter.dev');

    // 2. Prova a lanciarlo
    // mode: LaunchMode.externalApplication serve per aprire il browser vero e proprio (Chrome/Safari)
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Non riesco ad aprire $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // INTESTAZIONE (Header)
          const UserAccountsDrawerHeader(
            accountName: Text("Studente Flutter"),
            accountEmail: Text("studente@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
          ),
          
          // VOCE 1: Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context); // Chiude il drawer
            },
          ),
          
          const Divider(), // Una linea divisoria estetica
          
          // VOCE 2: Link esterno (NUOVO)
          ListTile(
            leading: const Icon(Icons.language, color: Colors.blue),
            title: const Text("Visita il sito ufficiale"),
            subtitle: const Text("flutter.dev"),
            onTap: () {
              Navigator.pop(context); // Chiude il drawer
              _apriSito(); // Lancia il link
            },
          ),
        ],
      ),
    );
  }
}