import 'package:flutter/material.dart';
import 'pokemon_card.dart';
import 'pokemon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

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

class StatBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;

  const StatBar({
    super.key,
    required this.label, 
    required this.value, 
    required this.maxValue, 
    required this.color
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label, 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              Text(
                "${value.toInt()} / ${maxValue.toInt()}", 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / maxValue, 
            color: color,
            backgroundColor: color.withOpacity(0.2),
            minHeight: 12,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }
}

class BattlePanel extends StatefulWidget {

  // para receber o pokemon selecionado
  final Pokemon pokemon;
  final String docId;

  const BattlePanel({super.key, required this.pokemon, required this.docId});

  @override
  State<BattlePanel> createState() => _BattlePanelState();
}

class _BattlePanelState extends State<BattlePanel> {

  late int nivel; 
  int hp = 100;
  int xp = 0;
  final int maxHp = 100;
  final int maxXp = 200;

  @override
  void initState() {
    super.initState();

    nivel = widget.pokemon.level;
  }

  void _atacar() {
    setState(() {
      hp = (hp - 20).clamp(0, maxHp);
      xp = (xp + 10).clamp(0, maxXp);
      
      if (xp >= maxXp) {
        nivel++;
        xp = 0; 
      }
    });
  }

  void _usarPocao() {
    setState(() {
      hp = (hp + 30).clamp(0, maxHp);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color hpColor = hp > 60 ? Colors.green : (hp > 30 ? Colors.yellow : Colors.red);
    
    // dinâmico, muda de acordo com o pokemon escolhido
    String statusMessage = hp == 0 ? "${widget.pokemon.name} desmaiou!" : (hp <= 30 ? "HP crítico!" : "");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            "Nível Atual: $nivel", 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)
          ),
          
          if (statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                statusMessage, 
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),

          const SizedBox(height: 10),

          StatBar(label: "HP", value: hp.toDouble(), maxValue: maxHp.toDouble(), color: hpColor),
          StatBar(label: "XP", value: xp.toDouble(), maxValue: maxXp.toDouble(), color: Colors.blue),
          
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: hp > 0 ? _atacar : null, 
                icon: const Icon(Icons.flash_on),
                label: const Text("ATACAR"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade100),
              ),
              ElevatedButton.icon(
                onPressed: hp < 100 ? _usarPocao : null, 
                icon: const Icon(Icons.health_and_safety),
                label: const Text("POÇÃO"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
              ),
            ],
          ),
          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () async {
              // manda novo nivel pro banco de dados
              await FirebaseFirestore.instance
                  .collection('pokemons')
                  .doc(widget.docId) 
                  .update({'level': nivel}); 

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text("ENCERRAR BATALHA"),
          ),
        ],
      ),
    );
  }
}

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