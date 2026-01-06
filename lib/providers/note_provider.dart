import 'package:flutter/material.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  
  List<Nota> _note = [];
  Nota? _notaSelezionata;

  // --- NUOVO: Variabili per la funzione "Annulla" ---
  Nota? _ultimaNotaEliminata;     // Qui salviamo la nota appena cancellata
  int? _ultimoIndiceEliminato;    // Qui salviamo la sua posizione (es. era la 3° nota)

  // Getter per sapere se c'è una nota da ripristinare
  bool get canUndo => _ultimaNotaEliminata != null;

  List<Nota> get note => _note;
  Nota? get notaSelezionata => _notaSelezionata;

  Future<void> caricaNote() async {
    _note = await _noteService.caricaNote();
    if (_note.isNotEmpty) {
      _notaSelezionata = _note[0];
    }
    notifyListeners();
  }

  void selezionaNota(Nota? nota) {
    _notaSelezionata = nota;
    notifyListeners();
  }

  void salvaNota(Nota notaSalvata, {Nota? notaEsistente}) {
    if (notaEsistente == null) {
      _note.add(notaSalvata);
      _notaSelezionata = notaSalvata;
    } else {
      notaEsistente.titolo = notaSalvata.titolo;
      notaEsistente.contenuto = notaSalvata.contenuto;
      notaEsistente.data = notaSalvata.data;
    }
    _noteService.salvaNote(_note);
    notifyListeners();
  }

  // --- MODIFICATO: Elimina con backup ---
  void eliminaNota(int index) {
    // 1. Prima di eliminare, facciamo il backup!
    _ultimaNotaEliminata = _note[index];
    _ultimoIndiceEliminato = index;

    // 2. Procediamo con l'eliminazione normale
    Nota daEliminare = _note[index];
    _note.removeAt(index);

    if (_note.isEmpty) {
      _notaSelezionata = null;
    } else if (_notaSelezionata == daEliminare) {
      _notaSelezionata = _note.isNotEmpty ? _note[0] : null;
    }

    _noteService.salvaNote(_note);
    notifyListeners();
  }

  // --- NUOVO: Funzione per ripristinare la nota ---
  void ripristinaNota() {
    // Controlliamo se abbiamo davvero qualcosa da ripristinare
    if (_ultimaNotaEliminata != null && _ultimoIndiceEliminato != null) {
      
      // Reinseriamo la nota ESATTAMENTE dove era prima
      _note.insert(_ultimoIndiceEliminato!, _ultimaNotaEliminata!);
      
      // Puliamo la memoria temporanea (non serve più)
      _ultimaNotaEliminata = null;
      _ultimoIndiceEliminato = null;

      // Salviamo e aggiorniamo la UI
      _noteService.salvaNote(_note);
      notifyListeners();
    }
  }
}