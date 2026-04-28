import 'package:flutter/material.dart';
import 'home_screen.dart'; 

class MoveList extends StatelessWidget {

  final Pokemon pokemon;

  const MoveList({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            "Golpes Especiais", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
        ),

        // passa por todos os golpes da lista
        for (var golpe in pokemon.moves)
          ListTile(
            leading: const Icon(Icons.bolt, color: Colors.orange, size: 30),
            title: Text(
              golpe, 
              style: const TextStyle(fontWeight: FontWeight.w500)
            ),
            trailing: const Icon(Icons.star_border, color: Colors.grey),
          ),
      ],
    );
  }
}