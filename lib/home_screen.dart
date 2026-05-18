import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'pokemon_screen.dart';
import 'new_pokemon_screen.dart';
import 'pokemon.dart';
import 'trainer_profile_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final collection = FirebaseFirestore.instance.collection('pokemons');

  Future<Map<String, dynamic>?> _getTrainerData() async {
    final doc = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc('treinador')
      .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        centerTitle: true,
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _getTrainerData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Pokédex Cloud');
            }

            final name = snapshot.data!['name'] ?? 'treinador';
            final avatarIndex = snapshot.data!['avatarIndex'] ?? 0;

            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 18,
                  child: Image.asset('assets/trainers/trainer_${avatarIndex + 1}.png')
                ),
                const SizedBox(width: 10),
                Text('Olá, $name', style: const TextStyle(fontSize: 18)),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainerProfileScreen()),
              );
              setState(() {});
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const NewPokemonScreen())
          );
        },
      ),
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
                spriteUrl: data['spriteUrl'] ?? '',
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