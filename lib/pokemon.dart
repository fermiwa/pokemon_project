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