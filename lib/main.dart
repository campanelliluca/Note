import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: Importiamo il pacchetto provider
import 'package:task_list/pages/note_page/note_page.dart';
import 'package:task_list/providers/note_provider.dart'; // IMPORTANTE: Importiamo il nostro nuovo cervello

void main() {
  runApp(
    // MultiProvider ci permette di iniettare il nostro "cervello" nell'app.
    // Usiamo MultiProvider perché se in futuro avrai un "UserProvider" o "SettingsProvider",
    // basterà aggiungerli alla lista 'providers' qui sotto.
    MultiProvider(
      providers: [
        // Qui creiamo l'istanza del NoteProvider.
        // Da ora in poi, qualsiasi widget nell'app potrà dire "Hey, dammi il NoteProvider!"
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le mie note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotePage(),
    );
  }
}