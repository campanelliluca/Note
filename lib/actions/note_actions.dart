import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/providers/note_provider.dart';
import 'package:task_list/pages/note_page/widgets/nota_dialog.dart';
import 'package:task_list/pages/note_page/widgets/note_detail_view.dart';

class NoteActions {
  
  static void apriDialogNota(BuildContext context, {Nota? nota}) {
    showDialog(
      context: context,
      builder: (ctx) => NotaDialog(
        notaEsistente: nota,
        onSave: (notaSalvata) {
          context.read<NoteProvider>().salvaNota(notaSalvata, notaEsistente: nota);
        },
      ),
    );
  }

// --- NUOVO: Eliminazione Immediata (Senza Dialog) ---
  static void eliminaImmediatamente(BuildContext context, int index, String titolo) {
    // 1. Eseguiamo l'eliminazione IMMEDIATA
    // (Nota: il backup viene fatto automaticamente dentro il Provider)
    context.read<NoteProvider>().eliminaNota(index);

    // 2. Mostriamo subito la SnackBar con Undo
    ScaffoldMessenger.of(context).clearSnackBars(); // Pulisce eventuali messaggi precedenti per evitare code
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Expanded(
              child: Text(
                'Nota "$titolo" eliminata',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'ANNULLA',
          textColor: Colors.amber,
          onPressed: () {
            context.read<NoteProvider>().ripristinaNota();
          },
        ),
      ),
    );
  }

  static void navigaAlDettaglioMobile(BuildContext context, Nota nota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: Text(nota.titolo)),
          body: NoteDetailView(
            nota: nota,
            onEdit: () {
              Navigator.pop(ctx);
              apriDialogNota(context, nota: nota);
            },
          ),
        ),
      ),
    );
  }
}