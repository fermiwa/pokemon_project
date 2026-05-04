import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPokemonScreen extends StatefulWidget {
  const NewPokemonScreen({super.key});

  @override
  State<NewPokemonScreen> createState() => _NewPokemonScreenState();
}

class _NewPokemonScreenState extends State<NewPokemonScreen> {

  final _formKey = GlobalKey<FormState>();

  // controllers para pegar oq for inserido
  final _nameController = TextEditingController();
  final _spriteIdController = TextEditingController();
  final _levelController = TextEditingController();

  final _spriteFocus = FocusNode();
  final _levelFocus = FocusNode();

  String _previewName = '';
  String? _selectedType;

  // lista com as possibilidades no dropdown
  final List<String> _types = [
    'Fogo', 'Água', 'Planta', 'Elétrico', 'Normal', 'Psíquico', 'Gelo', 'Dragão'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _spriteIdController.dispose();
    _levelController.dispose();
    _spriteFocus.dispose();
    _levelFocus.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await FirebaseFirestore.instance.collection('pokemons').add({
        'name': _nameController.text.trim(),
        'spriteId': int.parse(_spriteIdController.text),
        'level': int.parse(_levelController.text),
        'types': [_selectedType], 
        'spriteUrl': 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_spriteIdController.text}.png',
      });

      // (volta pra tela anterior
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pokémon'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview do Nome
              if (_previewName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Cadastrando: $_previewName...',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                  ),
                ),

              // Campo Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome do Pokémon', border: OutlineInputBorder()),
                textInputAction: TextInputAction.next,
                onChanged: (value) => setState(() => _previewName = value.trim()),
                onFieldSubmitted: (_) => _spriteFocus.requestFocus(),
                validator: (value) {
                  if (value == null || value.trim().length < 2) return 'Mínimo de 2 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Sprite ID
              TextFormField(
                controller: _spriteIdController,
                focusNode: _spriteFocus,
                decoration: const InputDecoration(labelText: 'Sprite ID (1-1025)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _levelFocus.requestFocus(),
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null || n < 1 || n > 1025) return 'ID inválido (1-1025)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Nível Inicial
              TextFormField(
                controller: _levelController,
                focusNode: _levelFocus,
                decoration: const InputDecoration(labelText: 'Nível Inicial (1-100)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null || n < 1 || n > 100) return 'Nível inválido (1-100)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Tipo
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo Principal', border: OutlineInputBorder()),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) => value == null ? 'Selecione um tipo' : null,
              ),
              const SizedBox(height: 32),

              // Botão Salvar
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('SALVAR POKÉMON', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}