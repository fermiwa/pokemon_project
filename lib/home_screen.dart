import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importante!
import 'pokemon_screen.dart';

// modelo que aceita os dados do firebase
class Pokemon {
  final String id; 
  final String name;
  final int spriteId;
  final List<String> types; 
  int level;
  final List<String> moves;

  String get spriteUrl => 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$spriteId.png';

  Pokemon({
    required this.id,
    required this.name,
    required this.spriteId,
    required this.types,
    required this.level,
    required this.moves,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final collection = FirebaseFirestore.instance.collection('pokemons');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex Cloud'),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      // StreamBuilder lê os dados em tempo real
      body: StreamBuilder<QuerySnapshot>(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar dados.'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              //final String docId = doc.id;

              final p = Pokemon(
                id: doc.id,
                name: data['name'] ?? 'Sem nome',
                spriteId: data['spriteId'] ?? 1,
                level: data['level'] ?? 1,
                types: List<String>.from(data['types'] ?? []),
                moves: ['Tackle', 'Growl'], 
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(p.spriteUrl),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Nível: ${p.level} • ${p.types.join("/")}'),
                  // botão de deletar o pokemon
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await collection.doc(p.id).delete();
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonScreen(
                          pokemon: p, 
                          docId: p.id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}