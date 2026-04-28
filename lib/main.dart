import 'package:flutter/material.dart';
import 'home_screen.dart'; 
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon Card',
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.red,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}