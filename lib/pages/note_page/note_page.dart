import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_list/providers/note_provider.dart';
import 'package:task_list/widgets/custom_app_bar.dart';
import 'package:task_list/widgets/custom_drawer.dart';
import 'package:task_list/pages/note_page/views/mobile_view.dart';
import 'package:task_list/pages/note_page/views/tablet_view.dart';
// Importiamo il nuovo file delle azioni
import 'package:task_list/actions/note_actions.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoteProvider>().caricaNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Ascoltiamo i dati dal Provider
    final provider = context.watch<NoteProvider>();
    final mieNote = provider.note;
    final notaSelezionata = provider.notaSelezionata;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Le mie Note'),
      drawer: const CustomDrawer(),
      
      floatingActionButton: FloatingActionButton(
        // Chiamata pulita alla classe Actions
        onPressed: () => NoteActions.apriDialogNota(context),
        child: const Icon(Icons.add),
      ),

      body: isMobile
          ? MobileView(
              note: mieNote,
              onTap: (nota) => NoteActions.navigaAlDettaglioMobile(context, nota),
              onEdit: (nota) => NoteActions.apriDialogNota(context, nota: nota),
              
              // --- MODIFICA QUI ---
              // Prima era: NoteActions.confermaEliminazione(...)
              // Ora è:
              onDelete: (index) => NoteActions.eliminaImmediatamente(context, index, mieNote[index].titolo),
            )
          : TabletView(
              note: mieNote,
              notaSelezionata: notaSelezionata,
              onTap: (nota) => provider.selezionaNota(nota),
              onEdit: (nota) => NoteActions.apriDialogNota(context, nota: nota),
              
              // --- MODIFICA ANCHE QUI (Tablet) ---
              onDelete: (index) => NoteActions.eliminaImmediatamente(context, index, mieNote[index].titolo),
            ),
    );
  }
}