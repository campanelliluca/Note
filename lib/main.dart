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
      title: 'DuoList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A9C89)),
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A9C89),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF8966),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const NotePage(),
    );
  }
}