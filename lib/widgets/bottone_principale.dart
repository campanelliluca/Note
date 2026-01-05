import 'package:flutter/material.dart';

class BottonePrincipale extends StatelessWidget {
  final String testo;
  final VoidCallback onPressed; // La funzione che verrà eseguita al click
  final IconData? icona;        // L'icona è opzionale (può essere null)

  const BottonePrincipale({
    super.key,
    required this.testo,
    required this.onPressed,
    this.icona,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(testo, style: const TextStyle(fontSize: 18)),
          if (icona != null) ...[
            const SizedBox(width: 10),
            Icon(icona),
          ],
        ],
      ),
    );
  }
}