import 'package:flutter/material.dart';

class TitoloH1 extends StatelessWidget {
  final String testo; // La variabile che conterrà il testo del titolo

  const TitoloH1({super.key, required this.testo});

  @override
  Widget build(BuildContext context) {
    return Text(
      testo,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }
}