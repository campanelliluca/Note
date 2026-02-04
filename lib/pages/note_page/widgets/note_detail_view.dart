import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _gestisciImmagine(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        imageQuality: 85,
      );
      
      if (photo == null) return;
      if (!mounted) return;

      setState(() {
        widget.nota.immaginePath = photo.path;
      });
      context.read<NoteProvider>().salvaNota(widget.nota, notaEsistente: widget.nota);
    } catch (e) {
      debugPrint("Errore immagine: $e");
    }
  }

  void _rimuoviFoto() {
    setState(() {
      widget.nota.immaginePath = null;
    });
    context.read<NoteProvider>().salvaNota(widget.nota, notaEsistente: widget.nota);
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

          const SizedBox(height: 10),

          // AREA FOTO
          if (widget.nota.immaginePath != null && widget.nota.immaginePath!.isNotEmpty)
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          widget.nota.immaginePath!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(widget.nota.immaginePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _rimuoviFoto,
                  style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.7)),
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _gestisciImmagine(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scatta Foto'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _gestisciImmagine(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Carica Foto'),
                ),
              ],
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