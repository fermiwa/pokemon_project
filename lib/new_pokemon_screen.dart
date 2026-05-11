import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pokemon_service.dart';

class NewPokemonScreen extends StatefulWidget {
  const NewPokemonScreen({super.key});

  @override
  State<NewPokemonScreen> createState() => _NewPokemonScreenState();
}

class _NewPokemonScreenState extends State<NewPokemonScreen> {
  // Estado
  late Future<List<String>> _searchFuture;
  final _queryController = TextEditingController();
  Map<String, dynamic>? _selected;
  bool _loadingDetails = false;
  final _levelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _searchFuture = fetchPokemonNames();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _buscar() {
    final query = _queryController.text.trim();
    setState(() {
      if (query.isEmpty) {
        _searchFuture = fetchPokemonNames();
      } else {
        _searchFuture = fetchPokemonByName(query);
      }
    });
  }

  Future<void> _selectPokemon(String name) async {
    setState(() {
      _loadingDetails = true;
    });

    try {
      final details = await fetchPokemonDetails(name);
      setState(() {
        _selected = details;
        _loadingDetails = false;
      });
    } catch (e) {
      setState(() {
        _loadingDetails = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar detalhes: $e')),
        );
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseFirestore.instance.collection('pokemons').add({
        'name': _selected!['name'],
        'spriteUrl': _selected!['spriteUrl'],
        'types': _selected!['types'],
        'level': int.parse(_levelController.text),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pokémon'),
        backgroundColor: Colors.redAccent,
      ),
      body: _loadingDetails
          ? const Center(child: CircularProgressIndicator())
          : _selected == null
              ? _buildList()
              : _buildForm(),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        // Campo de busca
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Pokémon',
                    border: OutlineInputBorder(),
                    hintText: 'Digite o nome...',
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _buscar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                ),
                child: const Text('Buscar'),
              ),
            ],
          ),
        ),

        // Lista de resultados
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _searchFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erro: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final names = snapshot.data!;
              if (names.isEmpty) {
                return const Center(child: Text('Nenhum Pokémon encontrado'));
              }

              return ListView.builder(
                itemCount: names.length,
                itemBuilder: (context, index) {
                  final name = names[index];
                  return ListTile(
                    title: Text(
                      name[0].toUpperCase() + name.substring(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _selectPokemon(name),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de preview
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(
                      _selected!['spriteUrl'],
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 120);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selected!['name'][0].toUpperCase() + 
                          _selected!['name'].substring(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selected = null;
                          _levelController.clear();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Trocar'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tipos como chips
            const Text(
              'Tipos:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: (_selected!['types'] as List<String>)
                  .map((type) => Chip(
                        label: Text(type),
                        backgroundColor: Colors.blue[100],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Campo de nível
            TextFormField(
              controller: _levelController,
              decoration: const InputDecoration(
                labelText: 'Nível Inicial (1-100)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null || n < 1 || n > 100) {
                  return 'Digite um nível entre 1 e 100';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Botão cadastrar
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'CADASTRAR',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
