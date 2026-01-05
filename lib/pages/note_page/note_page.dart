import 'package:flutter/material.dart';
// Import del modello e dei widget
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
  final List<Nota> mieNote = [
    Nota(titolo: 'Fare la spesa', contenuto: 'Latte, pane, uova e farina.', data: '02/01/2026'),
    Nota(titolo: 'Corso Flutter', contenuto: 'Studiare il refactoring.', data: '02/01/2026'),
  ];

  late Nota notaSelezionata;

  @override
  void initState() {
    super.initState();
    notaSelezionata = mieNote[0];
  }

  // --- FUNZIONE PER IL DIALOGO (Aggiunta/Modifica) ---
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
          });
        },
      ),
    );
  }

  // --- FUNZIONE PER ELIMINARE ---
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
                  notaSelezionata = Nota(titolo: 'Nessuna nota', contenuto: 'Crea una nota con +', data: '');
                } else if (notaSelezionata == daEliminare) {
                  notaSelezionata = mieNote[0];
                }
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
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: mieNote.length,
                itemBuilder: (context, index) => NoteListTile(
                  nota: mieNote[index],
                  isSelected: notaSelezionata == mieNote[index],
                  onTap: () => setState(() => notaSelezionata = mieNote[index]),
                  onEdit: () => _apriDialogNota(nota: mieNote[index]),
                  onDelete: () => _confermaEliminazione(index), // Ora è definita!
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: NoteDetailView(
              nota: notaSelezionata,
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