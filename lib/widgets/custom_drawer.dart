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
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // INTESTAZIONE (Header)
          UserAccountsDrawerHeader(
            accountName: const Text("Studente Flutter"),
            accountEmail: const Text("studente@example.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary, // Usa il Verde Salvia
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
            leading: Icon(Icons.language, color: theme.colorScheme.primary), // Icona verde
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