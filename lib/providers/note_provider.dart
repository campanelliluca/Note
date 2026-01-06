import 'package:flutter/material.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  
  List<Nota> _note = [];
  Nota? _notaSelezionata;

// --- NUOVO: Variabile per memorizzare cosa sta scrivendo l'utente ---
  String _testoRicerca = "";

  // Variabili per memorizzare temporaneamente cosa abbiamo cancellato
  Nota? _ultimaNotaEliminata;     // Qui salviamo la nota appena cancellata
  int? _ultimoIndiceEliminato;    // Qui salviamo la sua posizione (es. era la 3° nota)

  // Getter per sapere se c'è una nota da ripristinare
  // --- MODIFICATO: Getter per la lista delle note ---
  // Non restituiamo più direttamente "_note", ma una lista calcolata al volo.
  // La chiamiamo "noteFiltrate" per chiarezza.
  List<Nota> get noteFiltrate {
    // 1. Se la casella di ricerca è vuota, restituiamo tutto come prima.
    if (_testoRicerca.isEmpty) {
      return _note;
    } 
    // 2. Se c'è scritto qualcosa, filtriamo la lista.
    else {
      return _note.where((nota) {
        // Convertiamo tutto in minuscolo per trovare "Latte" anche se cerco "latte"
        final titoloLower = nota.titolo.toLowerCase();
        final contenutoLower = nota.contenuto.toLowerCase();
        final searchLower = _testoRicerca.toLowerCase();

        // La nota passa il filtro se il testo cercato è nel titolo O nel contenuto
        return titoloLower.contains(searchLower) || contenutoLower.contains(searchLower);
      }).toList();
    }
  }

  List<Nota> get note => _note;
  Nota? get notaSelezionata => _notaSelezionata;

  // --- NUOVO: Funzione per aggiornare la ricerca ---
  // Questa verrà chiamata dalla barra in alto ogni volta che scrivi una lettera
  void cerca(String testo) {
    _testoRicerca = testo;
    notifyListeners(); // Avvisa la UI di ridisegnarsi con la nuova lista filtrata
  }

  Future<void> caricaNote() async {
    _note = await _noteService.caricaNote();
    if (_note.isNotEmpty) {
      _notaSelezionata = _note[0];
    }
    notifyListeners();
  }

  // --- SELEZIONE NOTA ---
  void selezionaNota(Nota? nota) {
    _notaSelezionata = nota;
    notifyListeners();
  }

// --- AGGIUNTA O MODIFICA ---
  void salvaNota(Nota notaSalvata, {Nota? notaEsistente}) {
    if (notaEsistente == null) {
      // È una nuova nota
      _note.add(notaSalvata);
      _notaSelezionata = notaSalvata; 
    } else {
      // È una modifica: aggiorniamo i campi della nota esistente
      notaEsistente.titolo = notaSalvata.titolo;
      notaEsistente.contenuto = notaSalvata.contenuto;
      notaEsistente.data = notaSalvata.data;
      // Aggiorniamo anche il tipo di nota (Testo o Lista)
      notaEsistente.isList = notaSalvata.isList;
    }

    // Salviamo su disco
    _noteService.salvaNote(_note);
    
    // Aggiorniamo la grafica
    notifyListeners();
  }

  // --- ELIMINAZIONE ---
  // --- NUOVO: Elimina cercando l'oggetto (Sicuro per la ricerca) ---
  void eliminaNotaByObject(Nota notaDaEliminare) {
    // Chiediamo alla lista completa: "A che numero si trova questa nota?"
    int realIndex = _note.indexOf(notaDaEliminare);
    
    // Se la troviamo (indice diverso da -1), usiamo la funzione di eliminazione standard
    if (realIndex != -1) {
      eliminaNota(realIndex);
    }
  }
  
  // Modifichiamo eliminaNota per salvare il backup prima di cancellare
  void eliminaNota(int index) {
    // 1. Salviamo il backup per l'undo
    _ultimaNotaEliminata = _note[index];
    _ultimoIndiceEliminato = index;

    // 2. Procediamo con l'eliminazione standard
    Nota daEliminare = _note[index];
    _note.removeAt(index);

    // 3. Gestiamo la selezione (se abbiamo cancellato quella che stavamo guardando)
    if (_note.isEmpty) {
      _notaSelezionata = null;
    } else if (_notaSelezionata == daEliminare) {
      _notaSelezionata = _note.isNotEmpty ? _note[0] : null;
    }

    // 4. Salviamo e aggiorniamo
    _noteService.salvaNote(_note);
    notifyListeners();
  }

  // --- NUOVO: Funzione per ripristinare la nota ---
  void ripristinaNota() {
    // Controlliamo se c'è qualcosa da ripristinare
    if (_ultimaNotaEliminata != null && _ultimoIndiceEliminato != null) {
      
      // Reinseriamo la nota nella posizione originale
      _note.insert(_ultimoIndiceEliminato!, _ultimaNotaEliminata!);
      
      // Salviamo su disco
      _noteService.salvaNote(_note);
      
      // Aggiorniamo la UI
      notifyListeners();

      // Puliamo la memoria dell'undo (si può fare una volta sola)
      _ultimaNotaEliminata = null;
      _ultimoIndiceEliminato = null;
    }
  }
}