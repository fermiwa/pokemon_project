import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'https://pokeapi.co/api/v2';

/// Busca os primeiros 20 Pokémon da API
Future<List<String>> fetchPokemonNames() async {
  final url = Uri.parse('$_baseUrl/pokemon?limit=20');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Erro ao buscar lista de Pokémon');
  }

  final data = json.decode(response.body);
  final results = data['results'] as List;
  
  return results.map((p) => p['name'] as String).toList();
}

/// Busca um Pokémon específico por nome
Future<List<String>> fetchPokemonByName(String name) async {
  final url = Uri.parse('$_baseUrl/pokemon/${name.toLowerCase()}');
  final response = await http.get(url);

  if (response.statusCode == 404) {
    throw Exception('Pokémon não encontrado');
  }

  if (response.statusCode != 200) {
    throw Exception('Erro ao buscar Pokémon');
  }

  final data = json.decode(response.body);
  return [data['name'] as String];
}

/// Busca detalhes completos de um Pokémon
Future<Map<String, dynamic>> fetchPokemonDetails(String name) async {
  final url = Uri.parse('$_baseUrl/pokemon/${name.toLowerCase()}');
  final response = await http.get(url);

  if (response.statusCode == 404) {
    throw Exception('Pokémon não encontrado');
  }

  if (response.statusCode != 200) {
    throw Exception('Erro ao buscar detalhes do Pokémon');
  }

  final data = json.decode(response.body);
  
  // Extrai spriteUrl com fallback
  String spriteUrl = data['sprites']['front_default'];
  if (spriteUrl.isEmpty) {
    final id = data['id'];
    spriteUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
  }

  // Extrai tipos
  final typesData = data['types'] as List;
  final types = typesData.map((t) => t['type']['name'] as String).toList();

  return {
    'name': data['name'],
    'spriteUrl': spriteUrl,
    'types': types,
  };
}
