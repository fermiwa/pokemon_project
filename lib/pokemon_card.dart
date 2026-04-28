import 'package:flutter/material.dart';
import 'home_screen.dart'; 

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon; 

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              backgroundImage: NetworkImage(pokemon.spriteUrl),
            ),
            const SizedBox(height: 16),
            Text(
              pokemon.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Tipos: ${pokemon.types.join(' / ')}",
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}