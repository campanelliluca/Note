import 'package:flutter/material.dart';
import 'dart:convert'; // Serve per trasformare i dati in formato JSON (testo)
import 'package:shared_preferences/shared_preferences.dart'; // Serve per salvare sul telefono

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
  // Iniziamo con una lista vuota. Se ci sono dati, li caricheremo dopo.
  List<Nota> mieNote = []; 
  Nota? notaSelezionata;

  // initState viene eseguito UNA VOLTA sola, quando apri questa pagina.
  @override
  void initState() {
    super.initState();
    // Chiamiamo la funzione per leggere i dati dal disco
    _caricaNote(); 
  }

  // --- FUNZIONE 1: CARICARE I DATI ---
  Future<void> _caricaNote() async {
    // 1. Otteniamo l'accesso alla memoria del telefono
    final prefs = await SharedPreferences.getInstance();
    
    // 2. Cerchiamo se esiste una stringa salvata con la chiave 'mie_note_key'
    final String? noteJson = prefs.getString('mie_note_key');

    if (noteJson != null) {
      // Se abbiamo trovato dei dati, dobbiamo aggiornare l'interfaccia
      setState(() {
        // 3. Decodifichiamo: Da Testo JSON -> Lista di Mappe -> Lista di Note
        Iterable l = json.decode(noteJson);
        mieNote = List<Nota>.from(l.map((model) => Nota.fromJson(model)));
        
        // Se la lista non è vuota, selezioniamo la prima nota per mostrarla a destra
        if (mieNote.isNotEmpty) {
          notaSelezionata = mieNote[0];
        }
      });
    }
  }

  // --- FUNZIONE 2: SALVARE I DATI ---
  Future<void> _salvaNote() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Trasformiamo la Lista di Note in una lunga stringa di testo (JSON)
    // Usiamo il metodo .toJson() che abbiamo creato nel Passo 2
    final String encodedData = json.encode(mieNote.map((n) => n.toJson()).toList());
    
    // 2. Scriviamo questa stringa sul disco sovrascrivendo quella vecchia
    await prefs.setString('mie_note_key', encodedData);
  }

  // --- LOGICA DI AGGIUNTA / MODIFICA ---
  void _apriDialogNota({Nota? nota}) {
    showDialog(
      context: context,
      builder: (context) => NotaDialog(
        notaEsistente: nota,
        onSave: (notaSalvata) {
          setState(() {
            if (nota == null) {
              // È una nuova nota: la aggiungiamo alla lista
              mieNote.add(notaSalvata);
              notaSelezionata = notaSalvata;
            } else {
              // È una modifica: aggiorniamo i campi della nota esistente
              nota.titolo = notaSalvata.titolo;
              nota.contenuto = notaSalvata.contenuto;
              nota.data = notaSalvata.data;
            }
            // IMPORTANTE: Dopo aver modificato la lista, salviamo tutto!
            _salvaNote(); 
          });
        },
      ),
    );
  }

  // --- LOGICA DI ELIMINAZIONE ---
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
                // Rimuoviamo la nota dalla lista
                mieNote.removeAt(index);
                
                // Gestiamo cosa mostrare nel pannello di destra
                if (mieNote.isEmpty) {
                  notaSelezionata = null;
                } else if (notaSelezionata == daEliminare) {
                  notaSelezionata = mieNote.isNotEmpty ? mieNote[0] : null;
                }
                
                // IMPORTANTE: Dopo aver eliminato, salviamo la nuova lista!
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Le mie Note'),
      drawer: const CustomDrawer(),
      body: Row(
        children: [
          // COLONNA SINISTRA: LISTA
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
          // COLONNA DESTRA: DETTAGLIO
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _apriDialogNota(),
        child: const Icon(Icons.add),
      ),
    );
  }
}