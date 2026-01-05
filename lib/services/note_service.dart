import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_list/models/nota.dart';

class NoteService {
  static const String _key = 'mie_note_key';

  // Carica le note dalla memoria
  Future<List<Nota>> caricaNote() async {
    final prefs = await SharedPreferences.getInstance();
    final String? noteJson = prefs.getString(_key);

    if (noteJson != null) {
      Iterable l = json.decode(noteJson);
      return List<Nota>.from(l.map((model) => Nota.fromJson(model)));
    }
    return []; // Se non c'è nulla, restituisce lista vuota
  }

  // Salva le note nella memoria
  Future<void> salvaNote(List<Nota> note) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(note.map((n) => n.toJson()).toList());
    await prefs.setString(_key, encodedData);
  }
}