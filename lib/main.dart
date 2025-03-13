import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const CardGameApp(),
    ),
  );
}

// Card model class
class CardModel {
  final String front;
  final String back;
  bool isFaceUp;

  CardModel({required this.front, required this.back, this.isFaceUp = false});

  void flip() {
    isFaceUp = !isFaceUp;
  }
}

// Game state management with Provider
class GameState with ChangeNotifier {
  final List<CardModel> _cards = [
    CardModel(front: '🐱', back: '❓'),
    CardModel(front: '🐶', back: '❓'),
    CardModel(front: '🐱', back: '❓'),
    CardModel(front: '🐶', back: '❓'),
    CardModel(front: '🐦', back: '❓'),
    CardModel(front: '🐸', back: '❓'),
    CardModel(front: '🐸', back: '❓'),
    CardModel(front: '🐶', back: '❓'),
  ];

  List<CardModel> get cards => _cards;

  void flipCard(int index) {
    cards[index].flip();
    notifyListeners();
  }
}

class CardGameApp extends StatelessWidget {
  const CardGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(title: 'Card Game'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: gameState.cards.length,
            itemBuilder: (context, index) {
              final card = gameState.cards[index];
              return GestureDetector(
                onTap: () => gameState.flipCard(index),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: card.isFaceUp ? Colors.blue[200] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    card.isFaceUp ? card.front : card.back,
                    style: TextStyle(fontSize: 32),
                  ),
                )
              );
            },
          );
        },
      ),
    );
  }
}