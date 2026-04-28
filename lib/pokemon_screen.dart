import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'pokemon_card.dart';
import 'battle_panel.dart';
import 'move_list.dart';

class PokemonScreen extends StatelessWidget {
  final Pokemon pokemon;
  final String docId;

  const PokemonScreen({
    super.key, 
    required this.pokemon, 
    required this.docId
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            PokemonCard(pokemon: pokemon), 
            
            const SizedBox(height: 16),
            
            BattlePanel(pokemon: pokemon, docId: docId),
            
            const SizedBox(height: 16),
            
            MoveList(pokemon: pokemon),   
          ],
        ),
      ),
    );
  }
}