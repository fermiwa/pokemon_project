import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'stat_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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