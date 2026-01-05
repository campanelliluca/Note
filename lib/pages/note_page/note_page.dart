import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:task_list/models/nota.dart'; 
import 'package:task_list/widgets/custom_app_bar.dart';
import 'package:task_list/widgets/custom_drawer.dart';
import 'package:task_list/pages/note_page/widgets/note_list_tile.dart';
import 'package:task_list/pages/note_page/widgets/note_detail_view.dart';
import 'package:task_list/pages/note_page/widgets/nota_dialog.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  List<Nota> mieNote = [];
  Nota? notaSelezionata;

  @override
  void initState() {
    super.initState();
    _caricaNote(); 
  }

  Future<void> _caricaNote() async {
    final prefs = await SharedPreferences.getInstance();
    final String? noteJson = prefs.getString('mie_note_key');

    if (noteJson != null) {
      setState(() {
        Iterable l = json.decode(noteJson);
        mieNote = List<Nota>.from(l.map((model) => Nota.fromJson(model)));
        // Se siamo su tablet/PC, selezioniamo la prima nota. 
        // Su mobile non serve selezionarla subito.
        if (mieNote.isNotEmpty) {
          notaSelezionata = mieNote[0];
        }
      });
    }
  }

  Future<void> _salvaNote() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(mieNote.map((n) => n.toJson()).toList());
    await prefs.setString('mie_note_key', encodedData);
  }

  void _apriDialogNota({Nota? nota}) {
    showDialog(
      context: context,
      builder: (context) => NotaDialog(
        notaEsistente: nota,
        onSave: (notaSalvata) {
          setState(() {
            if (nota == null) {
              mieNote.add(notaSalvata);
              notaSelezionata = notaSalvata;
            } else {
              nota.titolo = notaSalvata.titolo;
              nota.contenuto = notaSalvata.contenuto;
              nota.data = notaSalvata.data;
            }
            _salvaNote(); 
          });
        },
      ),
    );
  }

  void _confermaEliminazione(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina nota'),
        content: Text('Vuoi eliminare "${mieNote[index].titolo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                Nota daEliminare = mieNote[index];
                mieNote.removeAt(index);
                if (mieNote.isEmpty) {
                  notaSelezionata = null;
                } else if (notaSelezionata == daEliminare) {
                  notaSelezionata = mieNote.isNotEmpty ? mieNote[0] : null;
                }
                _salvaNote(); 
              });
              Navigator.pop(context);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- NUOVA FUNZIONE: Navigazione Mobile ---
  // Quando sei sul telefono e clicchi una nota, apriamo una nuova schermata
  void _navigaAlDettaglioMobile(Nota nota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(nota.titolo)),
          // Riusiamo il widget che abbiamo già creato!
          body: NoteDetailView(
            nota: nota,
            onEdit: () {
              Navigator.pop(context); // Chiude la pagina dettaglio
              _apriDialogNota(nota: nota); // Apre il dialogo modifica
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. MISURIAMO LO SCHERMO
    // Se la larghezza è meno di 600 pixel, siamo su un telefono
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Le mie Note'),
      drawer: const CustomDrawer(),
      // 2. DECIDIAMO QUALE LAYOUT MOSTRARE
      body: isMobile 
        ? _buildMobileLayout() // Layout Telefono (Solo Lista)
        : _buildTabletLayout(), // Layout Tablet/PC (Diviso in due)
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _apriDialogNota(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- LAYOUT TELEFONO (Lista a tutto schermo) ---
  Widget _buildMobileLayout() {
    if (mieNote.isEmpty) {
      return const Center(child: Text("Nessuna nota salvata"));
    }
    return ListView.builder(
      itemCount: mieNote.length,
      itemBuilder: (context, index) => NoteListTile(
        nota: mieNote[index],
        isSelected: false, // Su mobile non evidenziamo la selezione nella lista
        onTap: () => _navigaAlDettaglioMobile(mieNote[index]), // Apre nuova pagina
        onEdit: () => _apriDialogNota(nota: mieNote[index]),
        onDelete: () => _confermaEliminazione(index),
      ),
    );
  }

  // --- LAYOUT TABLET/PC (Quello che avevi prima) ---
  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[100],
            child: mieNote.isEmpty
                ? const Center(child: Text("Nessuna nota salvata"))
                : ListView.builder(
                    itemCount: mieNote.length,
                    itemBuilder: (context, index) => NoteListTile(
                      nota: mieNote[index],
                      isSelected: notaSelezionata == mieNote[index],
                      onTap: () => setState(() => notaSelezionata = mieNote[index]),
                      onEdit: () => _apriDialogNota(nota: mieNote[index]),
                      onDelete: () => _confermaEliminazione(index),
                    ),
                  ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 2,
          child: notaSelezionata == null
              ? const Center(child: Text("Seleziona o crea una nota"))
              : NoteDetailView(
                  nota: notaSelezionata!,
                  onEdit: () => _apriDialogNota(nota: notaSelezionata),
                ),
        ),
      ],
    );
  }
}