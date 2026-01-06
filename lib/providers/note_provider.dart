import 'package:flutter/material.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/services/note_service.dart';

// Estendiamo ChangeNotifier: permette a questo file di "notificare" la grafica quando i dati cambiano.
class NoteProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  
  // Dati privati (si usa il trattino basso _ per renderli privati)
  List<Nota> _note = [];
  Nota? _notaSelezionata;

  // GETTERS: Servono per leggere i dati dall'esterno senza poterli sovrascrivere direttamente
  List<Nota> get note => _note;
  Nota? get notaSelezionata => _notaSelezionata;

  // --- CARICAMENTO DATI ---
  Future<void> caricaNote() async {
    _note = await _noteService.caricaNote();
    
    // Se abbiamo delle note, selezioniamo la prima di default (utile per Tablet)
    if (_note.isNotEmpty) {
      _notaSelezionata = _note[0];
    }
    
    // IMPORTANTE: Avvisa la UI che i dati sono pronti!
    notifyListeners();
  }

  // --- SELEZIONE NOTA (Per Tablet) ---
  void selezionaNota(Nota? nota) {
    _notaSelezionata = nota;
    notifyListeners(); // Ridisegna per mostrare i dettagli della nota selezionata
  }

  // --- AGGIUNTA O MODIFICA ---
  void salvaNota(Nota notaSalvata, {Nota? notaEsistente}) {
    if (notaEsistente == null) {
      // È una nuova nota
      _note.add(notaSalvata);
      _notaSelezionata = notaSalvata; // La selezioniamo subito
    } else {
      // È una modifica: aggiorniamo i campi della nota esistente
      notaEsistente.titolo = notaSalvata.titolo;
      notaEsistente.contenuto = notaSalvata.contenuto;
      notaEsistente.data = notaSalvata.data;
    }

    // Salviamo su disco
    _noteService.salvaNote(_note);
    
    // Aggiorniamo la grafica
    notifyListeners();
  }

  // --- ELIMINAZIONE ---
  void eliminaNota(int index) {
    Nota daEliminare = _note[index];
    _note.removeAt(index);

    // Gestione intelligente della selezione (se cancello quella che stavo guardando)
    if (_note.isEmpty) {
      _notaSelezionata = null;
    } else if (_notaSelezionata == daEliminare) {
      _notaSelezionata = _note[0];
    }

    // Salviamo su disco
    _noteService.salvaNote(_note);
    
    // Aggiorniamo la grafica
    notifyListeners();
  }
}