import 'package:flutter/material.dart';

class TestoCorpo extends StatelessWidget {
  final String testo;

  const TestoCorpo({super.key, required this.testo});

  @override
  Widget build(BuildContext context) {
    return Text(
      testo,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        height: 1.5, // Aggiunge un po' di spazio tra le righe per la leggibilità
      ),
    );
  }
}