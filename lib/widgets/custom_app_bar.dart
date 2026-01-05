import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      centerTitle: true,
      title: Text(title),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blueGrey[100],
            backgroundImage: const NetworkImage(
              'https://cdn.pixabay.com/photo/2025/08/23/12/07/portrait-9791880_960_720.png', // Un'immagine d'esempio
            ),
            // child: const Icon(Icons.person, size: 20, color: Colors.blueGrey),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}