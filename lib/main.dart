import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

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
  ]..shuffle(Random());

  List<CardModel> get cards => _cards;

  void flipCard(int index) {
    _cards[index].flip();
    notifyListeners();
  }
}

// Flip Animation Widget
class FlipCard extends StatefulWidget {
  final bool isFaceUp;
  final String frontImage;
  final String backImage;
  final VoidCallback onTap;

  const FlipCard({
    super.key,
    required this.isFaceUp,
    required this.frontImage,
    required this.backImage,
    required this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFaceUp) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value;
          final isFrontVisible = angle < pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(angle),
            child: isFrontVisible
                ? Image.asset(widget.backImage, height: 100, width: 100)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: Image.asset(widget.frontImage, height: 100, width: 100),
                  ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Main App Widget
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

// Home Page with Grid Layout
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
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
              return FlipCard(
                isFaceUp: card.isFaceUp,
                frontImage: 'assets/images/CardFront.jpg',
                backImage: 'assets/images/CardBack.jpg',
                onTap: () => gameState.flipCard(index),
              );
            },
          );
        },
      ),
    );
  }
}
