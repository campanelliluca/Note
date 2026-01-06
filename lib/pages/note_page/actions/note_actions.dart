import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/providers/note_provider.dart';
import 'package:task_list/pages/note_page/widgets/nota_dialog.dart';
import 'package:task_list/pages/note_page/widgets/note_detail_view.dart';

class NoteActions {
  
  // --- APRE IL DIALOG PER CREARE O MODIFICARE ---
  static void apriDialogNota(BuildContext context, {Nota? nota}) {
    showDialog(
      context: context,
      builder: (ctx) => NotaDialog(
        notaEsistente: nota,
        onSave: (notaSalvata) {
          // Usiamo read per accedere al provider ed eseguire l'azione
          context.read<NoteProvider>().salvaNota(notaSalvata, notaEsistente: nota);
        },
      ),
    );
  }

  // --- MOSTRA IL POPUP DI CONFERMA ELIMINAZIONE ---
  static void confermaEliminazione(BuildContext context, int index, String titolo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina nota'),
        content: Text('Vuoi eliminare "$titolo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text('Annulla')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<NoteProvider>().eliminaNota(index);
              Navigator.pop(ctx);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- NAVIGAZIONE MOBILE (Dettaglio) ---
  static void navigaAlDettaglioMobile(BuildContext context, Nota nota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: Text(nota.titolo)),
          body: NoteDetailView(
            nota: nota,
            onEdit: () {
              Navigator.pop(ctx); // Chiude la pagina di dettaglio
              // Richiama il metodo statico per aprire il dialog
              apriDialogNota(context, nota: nota);
            },
          ),
        ),
      ),
    );
  }
}