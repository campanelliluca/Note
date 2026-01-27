import 'dart:convert'; // Per jsonDecode
class Nota {
  String titolo;
  String contenuto;
  String data;
  bool isList; // <--- Deve esserci questo
  DateTime? dataCreazione; // NUOVO: L'orario preciso per l'ordinamento!

  Nota({
    required this.titolo, 
    required this.contenuto, 
    required this.data,
    this.isList = false,
    this.dataCreazione, // Facoltativo (per le note vecchie che non ce l'hanno)
  });

  Map<String, dynamic> toJson() {
    return {
      'titolo': titolo,
      'contenuto': contenuto,
      'data': data,
      'isList': isList, // <--- IMPORTANTE: Se manca questo, salva sempre come testo!
      // Salviamo la data precisa come stringa ISO (es. 2026-01-06T19:30:00)
      'dataCreazione': dataCreazione?.toIso8601String(),
    };
  }

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      titolo: json['titolo'],
      contenuto: json['contenuto'],
      data: json['data'],
      isList: json['isList'] ?? false, // <--- IMPORTANTE: Se manca questo, legge sempre come testo!
      // Se c'è la data precisa la leggiamo, altrimenti null
      dataCreazione: json['dataCreazione'] != null 
          ? DateTime.parse(json['dataCreazione']) 
          : null,
    );
  }

  // --- Metodo per generare il testo da condividere ---
  // --- VERSIONE CON EMOJI ---
  String getTestoCondivisibile() {
    StringBuffer buffer = StringBuffer();
    
    // 1. Titolo in maiuscolo con spaziatura
    buffer.writeln("📝 ${titolo.toUpperCase()}");
    buffer.writeln("📅 $data"); // Aggiungiamo anche la data, è utile!
    buffer.writeln("─────────────────"); // linea divisoria
    buffer.writeln(""); // Una riga vuota per dare aria

    if (isList) {
      try {
        List<dynamic> items = jsonDecode(contenuto);
        int fatti = 0;

        for (var item in items) {
          bool isFatto = item['fatto'];
          if (isFatto) fatti++;

          // Usa le EMOJI invece delle parentesi!
          // ✅ = Fatto
          // ⬜ = Da fare (puoi usare anche ⭕ o 🔲)
          // Se preferisci i simboli in bianco e nero, sostituisci "✅" con "☑" e "⬜" con "☐"
          String check = isFatto ? "✅" : "⬜"; 
          
          buffer.writeln("$check ${item['testo']}");
        }

        // 3. Aggiunta statistiche a fondo pagina
        buffer.writeln("");
        buffer.writeln("─────────────────"); // linea divisoria
        // Calcolo la percentuale o il numero
        buffer.writeln("Completati: $fatti su ${items.length}");

      } catch (e) {
        buffer.writeln("Errore nella lettura della lista.");
      }
    } else {
      // Testo semplice
      buffer.writeln(contenuto);
    }
    
    // Firma dell'app (opzionale, fa pubblicità alla tua app!)
    buffer.writeln("\nInvito da TaskList App 🚀");
    buffer.writeln("Scaricala qui: https://www.tuosito.com/download");

    return buffer.toString();
  }
}