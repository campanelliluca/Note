import 'dart:convert'; // Necessario per decodificare la lista JSON
import 'dart:io'; // Import necessario per gestire i file locali
import 'package:flutter/foundation.dart' show kIsWeb; // Import per la verifica della piattaforma Web
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
    final theme = Theme.of(context);

    return Card(
      // Rimuoviamo elevation: 0 per usare quella del tema (2)
      // Se selezionato usa un verde chiarissimo (primaryContainer), altrimenti bianco (default del tema)
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        
        // LEADING: Mostra la miniatura dell'immagine o un'icona di default
        leading: (nota.immaginePath != null && nota.immaginePath!.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8), // Arrotonda gli angoli
                child: SizedBox(
                  width: 50,
                  height: 50,
                  // Se siamo su Web usa Image.network, altrimenti Image.file
                  child: kIsWeb
                      ? Image.network(
                          nota.immaginePath!,
                          fit: BoxFit.cover, // Copre l'intero spazio disponibile
                        )
                      : Image.file(
                          File(nota.immaginePath!),
                          fit: BoxFit.cover,
                        ),
                ),
              )
            : Container(
                // Placeholder se l'immagine non è presente
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant, // Sfondo neutro dal tema
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.note, color: theme.colorScheme.onSurfaceVariant),
              ),

        // TITOLO + DATA (Sulla stessa riga)
        title: Row(
          children: [
            // Expanded sul titolo così se è lungo va a capo o si tronca senza spingere via la data
            Expanded(
              child: Text(
                nota.titolo.isEmpty ? "Senza titolo" : nota.titolo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
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
                color: isSelected ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7) : theme.colorScheme.outline,
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
              color: isSelected ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8) : theme.colorScheme.onSurfaceVariant,
              height: 1.3, // Migliora la leggibilità
            ),
          ),
        ),

        // EDIT BUTTON (A destra)
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined, color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.primary),
          onPressed: onEdit,
        ),
      ),
    );
  }
}