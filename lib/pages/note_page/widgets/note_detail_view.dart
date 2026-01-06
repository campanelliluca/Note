import 'dart:convert'; // Import necessario per leggere il JSON
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importiamo provider per salvare le modifiche al volo
import 'package:task_list/models/nota.dart';
import 'package:task_list/providers/note_provider.dart';
import 'package:task_list/widgets/titolo_h1.dart';
import 'package:task_list/widgets/testo_corpo.dart';

class NoteDetailView extends StatefulWidget {
  final Nota nota;
  final VoidCallback onEdit;

  const NoteDetailView({super.key, required this.nota, required this.onEdit});

  @override
  State<NoteDetailView> createState() => _NoteDetailViewState();
}

class _NoteDetailViewState extends State<NoteDetailView> {
  // Funzione per aggiornare lo stato del checkbox
  void _toggleCheck(int index, List<dynamic> listaAttuale) {
    setState(() {
      // 1. Invertiamo il valore 'fatto'
      listaAttuale[index]['fatto'] = !listaAttuale[index]['fatto'];
      
      // 2. Aggiorniamo la nota originale convertendo di nuovo in stringa
      widget.nota.contenuto = jsonEncode(listaAttuale);
      
      // 3. Chiamiamo il provider per salvare su disco le modifiche
      // Usiamo listen: false perché siamo dentro una funzione
      context.read<NoteProvider>().salvaNota(widget.nota, notaEsistente: widget.nota);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prepariamo il contenuto
    Widget contenutoWidget;

    if (widget.nota.isList) {
      // --- MODO LISTA ---
      List<dynamic> items = [];
      try {
        items = jsonDecode(widget.nota.contenuto);
      } catch (e) {
        items = [];
      }

      if (items.isEmpty) {
        contenutoWidget = const Text("Lista vuota");
      } else {
        contenutoWidget = ListView.builder(
          shrinkWrap: true, // Importante per stare dentro la colonna
          physics: const NeverScrollableScrollPhysics(), // Evita doppio scroll
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final bool isDone = item['fatto'] ?? false;
            
            return CheckboxListTile(
              title: Text(
                item['testo'],
                style: TextStyle(
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : null,
                ),
              ),
              value: isDone,
              onChanged: (val) => _toggleCheck(index, items),
              controlAffinity: ListTileControlAffinity.leading, // Checkbox a sinistra
              contentPadding: EdgeInsets.zero, // Meno spazio ai bordi
            );
          },
        );
      }
    } else {
      // --- MODO TESTO NORMALE ---
      contenutoWidget = InkWell(
        onTap: widget.onEdit,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: TestoCorpo(
            testo: widget.nota.contenuto.isEmpty 
                ? "Tocca qui per aggiungere un contenuto..." 
                : widget.nota.contenuto
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITOLO (Cliccabile per modifica)
          InkWell(
            onTap: widget.onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TitoloH1(testo: widget.nota.titolo.isEmpty ? "Senza titolo" : widget.nota.titolo),
            ),
          ),
          const SizedBox(height: 10),
          Text(widget.nota.data, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          
          const Divider(height: 40),
          
          // CONTENUTO (Lista o Testo)
          Expanded(
            child: SingleChildScrollView(
              child: contenutoWidget,
            ),
          ),
        ],
      ),
    );
  }
}