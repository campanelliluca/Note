import 'package:flutter/material.dart';
import 'package:task_list/models/nota.dart';

class NoteListTile extends StatelessWidget {
  final Nota nota;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete; // Questo parametro c'è ancora, ma verrà usato dallo Swipe
  final VoidCallback onEdit;

  const NoteListTile({
    super.key,
    required this.nota,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.blue[50],
      title: Text(
        nota.titolo.isEmpty ? "Senza titolo" : nota.titolo, 
        style: const TextStyle(fontWeight: FontWeight.bold)
      ),
      subtitle: Text(nota.data),
      trailing: IconButton(
        // Abbiamo tolto la Row e lasciato solo la matita
        icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
        onPressed: onEdit,
      ),
      onTap: onTap,
    );
  }
}