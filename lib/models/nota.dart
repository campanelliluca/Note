class Nota {
  String titolo;
  String contenuto;
  String data;
  bool isList; // <--- Deve esserci questo

  Nota({
    required this.titolo, 
    required this.contenuto, 
    required this.data,
    this.isList = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'titolo': titolo,
      'contenuto': contenuto,
      'data': data,
      'isList': isList, // <--- IMPORTANTE: Se manca questo, salva sempre come testo!
    };
  }

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      titolo: json['titolo'],
      contenuto: json['contenuto'],
      data: json['data'],
      isList: json['isList'] ?? false, // <--- IMPORTANTE: Se manca questo, legge sempre come testo!
    );
  }
}