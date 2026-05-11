// modelo que aceita os dados do firebase
class Pokemon {
  final String id; 
  final String name;
  final String spriteUrl;
  final List<String> types; 
  int level;
  final List<String> moves;

  Pokemon({
    required this.id,
    required this.name,
    required this.spriteUrl,
    required this.types,
    required this.level,
    required this.moves,
  });
}
