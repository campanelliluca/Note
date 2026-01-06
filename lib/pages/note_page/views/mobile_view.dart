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
      itemBuilder: (context, index) => NoteListTile(
        nota: note[index],
        isSelected: false,
        onTap: () => onTap(note[index]),
        onEdit: () => onEdit(note[index]),
        onDelete: () => onDelete(index),
      ),
    );
  }
}