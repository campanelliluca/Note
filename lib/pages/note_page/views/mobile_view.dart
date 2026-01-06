import 'package:flutter/material.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/pages/note_page/widgets/note_list_tile.dart';

class MobileView extends StatelessWidget {
  final List<Nota> note;
  final Function(Nota) onTap;
  final Function(Nota) onEdit;
  final Function(int) onDelete;

  const MobileView({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (note.isEmpty) {
      return const Center(child: Text("Nessuna nota salvata"));
    }
    
    return ListView.builder(
      itemCount: note.length,
      itemBuilder: (context, index) {
        final notaCorrente = note[index];

        // Dismissible è il widget che permette lo swipe
        return Dismissible(
          // KEY: Serve a Flutter per identificare univocamente questo widget nella lista.
          // Usiamo il titolo + l'indice per creare un ID unico temporaneo.
          key: ValueKey("${notaCorrente.titolo}_$index"),
          
          // DIRECTION: Permettiamo lo swipe solo da destra verso sinistra (End to Start)
          direction: DismissDirection.endToStart,

          // BACKGROUND: Cosa mostrare "sotto" la nota mentre trascini
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight, // Icona allineata a destra
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          // ONDISMISSED: Cosa succede quando lo swipe è completato
          onDismissed: (direction) {
            // Chiamiamo la funzione di eliminazione passata dal genitore
            onDelete(index);
          },

          // CHILD: Il contenuto vero e proprio (la nostra vecchia NoteListTile)
          child: NoteListTile(
            nota: notaCorrente,
            isSelected: false,
            onTap: () => onTap(notaCorrente),
            onEdit: () => onEdit(notaCorrente),
            onDelete: () => onDelete(index),
          ),
        );
      },
    );
  }
}