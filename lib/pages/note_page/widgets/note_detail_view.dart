import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart'; // <--- IMPORTANTE: Importiamo il pacchetto
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
  void _toggleCheck(int index, List<dynamic> listaAttuale) {
    setState(() {
      listaAttuale[index]['fatto'] = !listaAttuale[index]['fatto'];
      widget.nota.contenuto = jsonEncode(listaAttuale);
      context.read<NoteProvider>().salvaNota(widget.nota, notaEsistente: widget.nota);
    });
  }

  // --- FUNZIONE PER CONDIVIDERE ---
  void _condividiNota() {
    // Usiamo il metodo "intelligente" che abbiamo creato nel Modello
    String testoDaInviare = widget.nota.getTestoCondivisibile();
    
    // Apriamo il menu di condivisione nativo
    Share.share(testoDaInviare);
  }

  @override
  Widget build(BuildContext context) {
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            );
          },
        );
      }
    } else {
      // --- MODO TESTO ---
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
          
          // --- RIGA TITOLO + CONDIVIDI ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Allinea in alto se il titolo va a capo
            children: [
              // 1. IL TITOLO (Expanded prende tutto lo spazio rimasto)
              Expanded(
                child: InkWell(
                  onTap: widget.onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: TitoloH1(testo: widget.nota.titolo.isEmpty ? "Senza titolo" : widget.nota.titolo),
                  ),
                ),
              ),
              
              // 2. IL BOTTONE CONDIVIDI
              IconButton(
                icon: const Icon(Icons.share, color: Colors.blue), // Icona blu per risaltare
                tooltip: 'Condividi nota',
                onPressed: _condividiNota, // Chiama la funzione
              ),
            ],
          ),

          const SizedBox(height: 10),
          
          // DATA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(widget.nota.data, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          
          const Divider(height: 40),
          
          // CONTENUTO
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