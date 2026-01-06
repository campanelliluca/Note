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
    
    // Usiamo PostFrameCallback per eseguire codice DOPO che la grafica è stata disegnata
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Carichiamo le note dal database
      await context.read<NoteProvider>().caricaNote();
      
      // 2. Controllo di sicurezza: verifichiamo che la pagina sia ancora aperta
      if (!mounted) return;

      // 3. Recuperiamo le note per vedere se la lista è piena
      final notePresenti = context.read<NoteProvider>().note;

      // 4. Se ci sono note, mostriamo il suggerimento
      if (notePresenti.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueGrey, // Colore diverso per distinguerlo dall'eliminazione
            content: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.yellow), // Icona lampadina
                SizedBox(width: 10),
                Expanded(child: Text("Suggerimento: Scorri a sinistra per eliminare")),
              ],
            ),
            duration: Duration(seconds: 5),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Ascoltiamo i dati dal Provider
    final provider = context.watch<NoteProvider>();
    // PRIMA ERA: final mieNote = provider.note;
    // ORA DIVENTA:
    final mieNote = provider.noteFiltrate;
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
              // L'indice che riceviamo qui è quello della lista FILTRATA.
              // Quindi mieNote[index] è esattamente la nota che stiamo guardando.
              // La passiamo intera alla nuova funzione eliminaImmediatamente.
              onDelete: (index) => NoteActions.eliminaImmediatamente(context, mieNote[index]),
            )
          : TabletView(
              note: mieNote,
              notaSelezionata: notaSelezionata,
              onTap: (nota) => provider.selezionaNota(nota),
              onEdit: (nota) => NoteActions.apriDialogNota(context, nota: nota),
              
              // --- MODIFICA ANCHE QUI ---
              onDelete: (index) => NoteActions.eliminaImmediatamente(context, mieNote[index]),
            ),
    );
  }
}