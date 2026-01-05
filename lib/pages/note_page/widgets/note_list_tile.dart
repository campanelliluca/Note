import 'package:flutter/material.dart';
// Import assoluto invece di quello relativo
import 'package:task_list/models/nota.dart';

class NoteListTile extends StatelessWidget {
  final Nota nota;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}