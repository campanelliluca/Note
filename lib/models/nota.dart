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
}