import 'package:flutter/material.dart';
// Import assoluti per la pagina e i widget globali
import 'package:task_list/widgets/titolo_h1.dart';
import 'package:task_list/widgets/testo_corpo.dart';
import 'package:task_list/models/nota.dart';

class NoteDetailView extends StatelessWidget {
  final Nota nota;
  final VoidCallback onEdit;

  const NoteDetailView({super.key, required this.nota, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: TitoloH1(testo: nota.titolo.isEmpty ? "Senza titolo" : nota.titolo),
            ),
          ),
          const SizedBox(height: 10),
          Text(nota.data, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 40),
          Expanded(
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                child: TestoCorpo(
                  testo: nota.contenuto.isEmpty ? "Tocca qui per aggiungere un contenuto..." : nota.contenuto
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}