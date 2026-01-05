import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_list/models/nota.dart';

class NotaDialog extends StatefulWidget {
  final Nota? notaEsistente;
  final Function(Nota) onSave;

  const NotaDialog({super.key, this.notaEsistente, required this.onSave});

  @override
  State<NotaDialog> createState() => _NotaDialogState();
}

class _NotaDialogState extends State<NotaDialog> {
  final TextEditingController _controllerTitolo = TextEditingController();
  final TextEditingController _controllerContenuto = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.notaEsistente != null) {
      _controllerTitolo.text = widget.notaEsistente!.titolo;
      _controllerContenuto.text = widget.notaEsistente!.contenuto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.notaEsistente == null ? 'Aggiungi nota' : 'Modifica nota'),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _controllerTitolo, decoration: const InputDecoration(labelText: 'Titolo')),
            const SizedBox(height: 10),
            TextField(controller: _controllerContenuto, decoration: const InputDecoration(labelText: 'Contenuto'), maxLines: 5),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        ElevatedButton(
          onPressed: () {
            if (_controllerTitolo.text.isNotEmpty) {
              final nota = Nota(
                titolo: _controllerTitolo.text,
                contenuto: _controllerContenuto.text,
                data: DateFormat('dd/MM/yyyy').format(DateTime.now()),
              );
              widget.onSave(nota);
              Navigator.pop(context);
            }
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}