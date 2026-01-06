import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/providers/note_provider.dart';
import 'package:task_list/pages/note_page/widgets/nota_dialog.dart';
import 'package:task_list/pages/note_page/widgets/note_detail_view.dart';

class NoteActions {
  
  // --- FUNZIONE DI SUPPORTO PER IL SUGGERIMENTO ---
  static void _mostraSuggerimentoSwipe(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.blueGrey,
        content: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.yellow),
            SizedBox(width: 10),
            Expanded(child: Text("Suggerimento: Scorri a sinistra per eliminare")),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void apriDialogNota(BuildContext context, {Nota? nota}) {
    showDialog(
      context: context,
      builder: (ctx) => NotaDialog(
        notaEsistente: nota,
        onSave: (notaSalvata) {
          // Controlliamo se stiamo creando una nuova nota (nota == null)
          // o se ne stiamo modificando una esistente (nota != null)
          bool isNuovaNota = (nota == null);

          // 1. Salviamo
          context.read<NoteProvider>().salvaNota(notaSalvata, notaEsistente: nota);
          
          // 2. Se è una NUOVA nota, mostriamo il suggerimento per lo swipe!
          if (isNuovaNota) {
            // Un piccolo ritardo per dare tempo al dialog di chiudersi
            Future.delayed(const Duration(milliseconds: 300), () {
               // Verifica di sicurezza (se l'utente è ancora nella pagina)
              if (context.mounted) {
                _mostraSuggerimentoSwipe(context);
              }
            });
          }
        },
      ),
    );
  }

  // CAMBIAMENTO: Ora accettiamo l'oggetto 'Nota' intero, non l'indice e il titolo separati
  static void eliminaImmediatamente(BuildContext context, Nota nota) {
    
    // Usiamo il nuovo metodo sicuro del provider
    context.read<NoteProvider>().eliminaNotaByObject(nota);

    ScaffoldMessenger.of(context).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Expanded(
              child: Text(
                // Usiamo il titolo preso direttamente dall'oggetto
                'Nota "${nota.titolo}" eliminata',
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