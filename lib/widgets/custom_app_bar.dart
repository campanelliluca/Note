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

    // Recuperiamo l'ordinamento attuale per spuntare la voce attiva nel menu
    final currentSort = context.select<NoteProvider, TipoOrdinamento>((p) => p.ordinamento);

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
        // --- NUOVO: BOTTONE ORDINAMENTO ---
        // Lo mostriamo solo se NON stiamo cercando (per pulizia), 
        // oppure possiamo lasciarlo sempre. Lasciamolo sempre per ora.
        if (!_isSearching) 
          PopupMenuButton<TipoOrdinamento>(
            icon: const Icon(Icons.sort), // Icona con le righette
            tooltip: 'Ordina note',
            initialValue: currentSort, // Evidenzia la scelta attuale
            onSelected: (TipoOrdinamento nuovoOrdine) {
              // Chiama il provider e cambia l'ordine
              context.read<NoteProvider>().cambiaOrdinamento(nuovoOrdine);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<TipoOrdinamento>>[
              const PopupMenuItem(
                value: TipoOrdinamento.dataRecente,
                child: Row(
                  children: [Icon(Icons.arrow_downward, size: 18), SizedBox(width: 8), Text('Più recenti')],
                ),
              ),
              const PopupMenuItem(
                value: TipoOrdinamento.dataVecchia,
                child: Row(
                  children: [Icon(Icons.arrow_upward, size: 18), SizedBox(width: 8), Text('Più vecchie')],
                ),
              ),
              const PopupMenuDivider(), // Una riga divisoria estetica
              const PopupMenuItem(
                value: TipoOrdinamento.alfabeticoAZ,
                child: Row(
                  children: [Icon(Icons.sort_by_alpha, size: 18), SizedBox(width: 8), Text('A - Z')],
                ),
              ),
              const PopupMenuItem(
                value: TipoOrdinamento.alfabeticoZA,
                child: Row(
                  children: [Icon(Icons.sort_by_alpha, size: 18), SizedBox(width: 8), Text('Z - A')],
                ),
              ),
            ],
          ),
          
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