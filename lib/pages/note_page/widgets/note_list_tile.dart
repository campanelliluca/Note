import 'dart:convert'; // Necessario per decodificare la lista JSON
import 'package:flutter/material.dart';
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

  // Funzione per generare il testo dell'anteprima
  String _getAnteprima() {
    if (nota.contenuto.isEmpty) {
      return "Nessun contenuto";
    }

    if (nota.isList) {
      // Se è una lista, dobbiamo trasformare il JSON in un testo leggibile
      try {
        List<dynamic> lista = jsonDecode(nota.contenuto);
        // Mappiamo la lista per prendere solo il testo e uniamo con virgola e spazio
        List<String> voci = lista.map((e) => e['testo'].toString()).toList();
        return voci.join(", "); // Esempio: "Latte, Pane, Uova"
      } catch (e) {
        return "Lista (errore anteprima)";
      }
    } else {
      // Se è testo normale, restituiamo il contenuto così com'è
      // Sostituiamo i ritorni a capo con spazi per l'anteprima
      return nota.contenuto.replaceAll('\n', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Usiamo una Card per dare un leggero rilievo e bordi arrotondati, sta meglio con l'anteprima
      elevation: 0, // Puoi aumentare se vuoi l'ombra
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // Spazio tra le note
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        
        // TITOLO + DATA (Sulla stessa riga)
        title: Row(
          children: [
            // Expanded sul titolo così se è lungo va a capo o si tronca senza spingere via la data
            Expanded(
              child: Text(
                nota.titolo.isEmpty ? "Senza titolo" : nota.titolo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10), // Spazio tra titolo e data
            
            // La DATA ora è qui, più piccola e grigia
            Text(
              nota.data,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),

        // ANTEPRIMA DEL CONTENUTO (Sotto il titolo)
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0), // Un po' di aria dal titolo
          child: Text(
            _getAnteprima(),
            maxLines: 2, // Massimo 2 righe di anteprima
            overflow: TextOverflow.ellipsis, // Mette i puntini (...) se è troppo lungo
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.3, // Migliora la leggibilità
            ),
          ),
        ),

        // EDIT BUTTON (A destra)
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
          onPressed: onEdit,
        ),
      ),
    );
  }
}