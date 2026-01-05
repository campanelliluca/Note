import 'package:flutter/material.dart';
// Import dei Service
import 'package:task_list/services/note_service.dart';
// Import dei Modelli
import 'package:task_list/models/nota.dart';
// Import dei Widget Generali
import 'package:task_list/widgets/custom_app_bar.dart';
import 'package:task_list/widgets/custom_drawer.dart';
// Import dei Widget Specifici (che abbiamo appena creato)
import 'package:task_list/pages/note_page/widgets/mobile_view.dart';
import 'package:task_list/pages/note_page/widgets/tablet_view.dart';
import 'package:task_list/pages/note_page/widgets/nota_dialog.dart';
import 'package:task_list/pages/note_page/widgets/note_detail_view.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final NoteService _noteService = NoteService(); // Istanziamo il service
  List<Nota> mieNote = [];
  Nota? notaSelezionata;

  @override
  void initState() {
    super.initState();
    _caricaDati();
  }

  // Usiamo il Service per caricare
  Future<void> _caricaDati() async {
    final noteCaricate = await _noteService.caricaNote();
    setState(() {
      mieNote = noteCaricate;
      if (mieNote.isNotEmpty) {
        notaSelezionata = mieNote[0];
      }
    });
  }

  // Usiamo il Service per salvare
  Future<void> _salvaDati() async {
    await _noteService.salvaNote(mieNote);
  }

  void _apriDialogNota({Nota? nota}) {
    showDialog(
      context: context,
      builder: (context) => NotaDialog(
        notaEsistente: nota,
        onSave: (notaSalvata) {
          setState(() {
            if (nota == null) {
              mieNote.add(notaSalvata);
              notaSelezionata = notaSalvata;
            } else {
              nota.titolo = notaSalvata.titolo;
              nota.contenuto = notaSalvata.contenuto;
              nota.data = notaSalvata.data;
            }
            _salvaDati();
          });
        },
      ),
    );
  }

  void _confermaEliminazione(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina nota'),
        content: Text('Vuoi eliminare "${mieNote[index].titolo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                Nota daEliminare = mieNote[index];
                mieNote.removeAt(index);
                if (mieNote.isEmpty) {
                  notaSelezionata = null;
                } else if (notaSelezionata == daEliminare) {
                  notaSelezionata = mieNote.isNotEmpty ? mieNote[0] : null;
                }
                _salvaDati();
              });
              Navigator.pop(context);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigaAlDettaglioMobile(Nota nota) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(nota.titolo)),
          body: NoteDetailView(
            nota: nota,
            onEdit: () {
              Navigator.pop(context);
              _apriDialogNota(nota: nota);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Le mie Note'),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _apriDialogNota(),
        child: const Icon(Icons.add),
      ),
      // Il body ora è super pulito: sceglie solo quale file mostrare!
      body: isMobile
          ? MobileView(
              note: mieNote,
              onTap: (nota) => _navigaAlDettaglioMobile(nota),
              onEdit: (nota) => _apriDialogNota(nota: nota),
              onDelete: (index) => _confermaEliminazione(index),
            )
          : TabletView(
              note: mieNote,
              notaSelezionata: notaSelezionata,
              onTap: (nota) => setState(() => notaSelezionata = nota),
              onEdit: (nota) => _apriDialogNota(nota: nota),
              onDelete: (index) => _confermaEliminazione(index),
            ),
    );
  }
}