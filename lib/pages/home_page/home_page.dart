import 'package:flutter/material.dart';
import 'package:task_list/widgets/custom_app_bar.dart';
import 'package:task_list/widgets/custom_drawer.dart';
import 'package:task_list/widgets/titolo_h1.dart';
import 'package:task_list/widgets/testo_corpo.dart';
import 'package:task_list/widgets/bottone_principale.dart';
import 'package:task_list/pages/note_page/note_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Blocco Note'),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Column(
              children: [
                Image.network(
                  'https://cdn.pixabay.com/photo/2013/07/13/09/41/organizer-155952_1280.png',
                  width: 400,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                const TitoloH1(testo: 'Blocco Note'),
                const SizedBox(height: 10),
                const TestoCorpo(testo: 'Benvenuto nella tua app di note'),
                const SizedBox(height: 30),
                BottonePrincipale(
                  testo: 'Vai alle note',
                  icona: Icons.arrow_forward,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}