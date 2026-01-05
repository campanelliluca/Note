class Nota {
  String titolo;
  String contenuto;
  String data;

  Nota({required this.titolo, required this.contenuto, required this.data});

  // --- TRADUTTORE PER IL SALVATAGGIO ---
  // Trasforma la Nota in una "Mappa" (un dizionario chiave-valore).
  // Esempio: "titolo" -> "Spesa", "contenuto" -> "Latte"
  Map<String, dynamic> toJson() {
    return {
      'titolo': titolo,
      'contenuto': contenuto,
      'data': data,
    };
  }

  // --- TRADUTTORE PER IL CARICAMENTO ---
  // Prende una Mappa dal disco e crea un nuovo oggetto Nota utilizzabile dall'app.
  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      titolo: json['titolo'],
      contenuto: json['contenuto'],
      data: json['data'],
    );
  }
}