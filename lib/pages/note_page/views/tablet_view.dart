import 'package:flutter/material.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/pages/note_page/widgets/note_list_tile.dart';
import 'package:task_list/pages/note_page/widgets/note_detail_view.dart';

class TabletView extends StatelessWidget {
  final List<Nota> note;
  final Nota? notaSelezionata;
  final Function(Nota) onTap;
  final Function(Nota) onEdit;
  final Function(int) onDelete;

  const TabletView({
    super.key,
    required this.note,
    required this.notaSelezionata,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Colonna Sinistra (Lista con Swipe)
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[100],
            child: note.isEmpty
                ? const Center(child: Text("Nessuna nota salvata"))
                : ListView.builder(
                    itemCount: note.length,
                    itemBuilder: (context, index) {
                      final notaCorrente = note[index];

                      // --- NUOVO: Aggiunto Dismissible anche qui ---
                      return Dismissible(
                        key: ValueKey("${notaCorrente.titolo}_$index"),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          onDelete(index);
                        },
                        child: NoteListTile(
                          nota: notaCorrente,
                          isSelected: notaSelezionata == notaCorrente,
                          onTap: () => onTap(notaCorrente),
                          onEdit: () => onEdit(notaCorrente),
                          onDelete: () => onDelete(index),
                        ),
                      );
                    },
                  ),
          ),
        ),
        
        const VerticalDivider(width: 1),
        
        // Colonna Destra (Dettaglio - invariata)
        Expanded(
          flex: 2,
          child: notaSelezionata == null
              ? const Center(child: Text("Seleziona o crea una nota"))
              : NoteDetailView(
                  nota: notaSelezionata!,
                  onEdit: () => onEdit(notaSelezionata!),
                ),
        ),
      ],
    );
  }
}