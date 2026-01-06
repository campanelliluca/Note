import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_list/providers/note_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  // Variabile per sapere se la barra di ricerca è attiva
  bool _isSearching = false; 
  
  // Controller per gestire il testo scritto
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose(); // Pulizia della memoria quando la barra viene distrutta
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // --- IL TITOLO CAMBIA DINAMICAMENTE ---
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true, // Appena apri, la tastiera sale subito
              style: const TextStyle(color: Colors.black), 
              decoration: const InputDecoration(
                hintText: 'Cerca nota...', // Testo fantasma
                border: InputBorder.none, // Nessuna riga sotto
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onChanged: (val) {
                // Ogni volta che scrivi una lettera, avvisiamo il Provider!
                context.read<NoteProvider>().cerca(val);
              },
            )
          : Text(widget.title), // Se non cerco, mostro il titolo normale
      
      actions: [
        // --- IL BOTTONE A DESTRA ---
        IconButton(
          // L'icona cambia: Lente se chiusa, Croce se aperta
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                // --- STO CHIUDENDO LA RICERCA ---
                _isSearching = false;
                _searchController.clear(); // Pulisco il testo visivo
                context.read<NoteProvider>().cerca(""); // Resetto il filtro nel Provider (mostra tutto)
              } else {
                // --- STO APRENDO LA RICERCA ---
                _isSearching = true;
              }
            });
          },
        ),
      ],
    );
  }
}