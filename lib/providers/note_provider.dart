import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_list/models/nota.dart';
import 'package:task_list/services/note_service.dart';

// --- NUOVO: Definiamo i tipi di ordinamento possibili ---
enum TipoOrdinamento {
  dataRecente,  // Dal più nuovo al più vecchio (Default)
  dataVecchia,  // Dal più vecchio al più nuovo
  alfabeticoAZ, // A -> Z
  alfabeticoZA  // Z -> A
}
class NoteProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();
  
  List<Nota> _note = [];
  Nota? _notaSelezionata;

  // Variabile per memorizzare cosa sta scrivendo l'utente ---
  String _testoRicerca = "";

  // Variabile per l'ordinamento (Default: Più recenti in alto) ---
  TipoOrdinamento _ordinamento = TipoOrdinamento.dataRecente;
  // Getter per sapere l'ordinamento attuale (servirà alla UI per colorare il bottone)
  TipoOrdinamento get ordinamento => _ordinamento;



  // Getter per sapere se c'è una nota da ripristinare
  // --- MODIFICATO: Getter per la lista delle note ---
  // Non restituiamo più direttamente "_note", ma una lista calcolata al volo.
  // La chiamiamo "noteFiltrate" per chiarezza.
  List<Nota> get noteFiltrate {
    // 1. Prima FILTRIAMO (come abbiamo fatto nel passo precedente)
    List<Nota> risultato;
    if (_testoRicerca.isEmpty) {
      risultato = [..._note]; // Creiamo una copia della lista per non toccare l'originale
    } else {
      risultato = _note.where((nota) {
        final titoloLower = nota.titolo.toLowerCase();
        final contenutoLower = nota.contenuto.toLowerCase();
        final searchLower = _testoRicerca.toLowerCase();
        return titoloLower.contains(searchLower) || contenutoLower.contains(searchLower);
      }).toList();
    }

    // 2. Poi ORDINIAMO la lista filtrata
    risultato.sort((a, b) {
      switch (_ordinamento) {
        case TipoOrdinamento.alfabeticoAZ:
          // Confronto stringhe standard (case insensitive)
          return a.titolo.toLowerCase().compareTo(b.titolo.toLowerCase());
          
        case TipoOrdinamento.alfabeticoZA:
          // Al contrario (b compare a)
          return b.titolo.toLowerCase().compareTo(a.titolo.toLowerCase());
          
        case TipoOrdinamento.dataVecchia:
          // Usiamo la dataCreazione se c'è, altrimenti proviamo a parsare la stringa data
          DateTime dataA = a.dataCreazione ?? DateFormat('dd/MM/yyyy').parse(a.data);
          DateTime dataB = b.dataCreazione ?? DateFormat('dd/MM/yyyy').parse(b.data);
          return dataA.compareTo(dataB); // A < B (Vecchio -> Nuovo)
          
        case TipoOrdinamento.dataRecente:
          DateTime dataA = a.dataCreazione ?? DateFormat('dd/MM/yyyy').parse(a.data);
          DateTime dataB = b.dataCreazione ?? DateFormat('dd/MM/yyyy').parse(b.data);
          return dataB.compareTo(dataA); // B < A (Nuovo -> Vecchio)
      }
    });

    return risultato;
  }

  // --- NUOVO: Funzione per cambiare ordinamento ---
  void cambiaOrdinamento(TipoOrdinamento nuovoOrdinamento) {
    _ordinamento = nuovoOrdinamento;
    notifyListeners(); // Ridisegna la lista ordinata!
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
    // Variabili per memorizzare temporaneamente cosa abbiamo cancellato
  Nota? _ultimaNotaEliminata;     // Qui salviamo la nota appena cancellata
  int? _ultimoIndiceEliminato;    // Qui salviamo la sua posizione (es. era la 3° nota)

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