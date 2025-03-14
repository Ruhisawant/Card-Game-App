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
  bool isMatched;

  CardModel({required this.front, required this.back, this.isFaceUp = false, this.isMatched = false});

  void flip() {
    isFaceUp = !isFaceUp;
  }
}

// Game state management with Provider
class GameState with ChangeNotifier {
  final List<String> _cardImages = [
    'assets/images/cards/2_of_clubs.png',
    'assets/images/cards/3_of_diamonds.png',
    'assets/images/cards/4_of_hearts.png',
    'assets/images/cards/5_of_spades.png',
    'assets/images/cards/6_of_clubs.png',
    'assets/images/cards/7_of_diamonds.png',
    'assets/images/cards/8_of_hearts.png',
    'assets/images/cards/9_of_spades.png',
  ];

  final List<CardModel> _cards = [];
  CardModel? _firstFlippedCard;
  int? _firstFlippedIndex;
  bool _isChecking = false;
  bool get isGameWon => _cards.every((card) => card.isMatched);

  List<CardModel> get cards => _cards;

  GameState() {
    _initializeCards();
  }

  void _initializeCards() {
    List<String> shuffledImages = [..._cardImages, ..._cardImages]..shuffle(Random());
    _cards.clear();
    for (var image in shuffledImages) {
      _cards.add(CardModel(front: image, back: 'assets/images/cardBack.jpg'));
    }
    notifyListeners();
  }

  void flipCard(int index) {
    if (_isChecking || _cards[index].isFaceUp || _cards[index].isMatched) return;

    _cards[index].flip();
    notifyListeners();

    if (_firstFlippedCard == null) {
      _firstFlippedCard = _cards[index];
      _firstFlippedIndex = index;
    } else {
      _isChecking = true;
      if (_firstFlippedCard!.front == _cards[index].front) {
        _cards[index].isMatched = true;
        _cards[_firstFlippedIndex!].isMatched = true;
        _resetSelection();
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          _cards[index].flip();
          _cards[_firstFlippedIndex!].flip();
          _resetSelection();
        });
      }
    }
  }

  void _resetSelection() {
    _firstFlippedCard = null;
    _firstFlippedIndex = null;
    _isChecking = false;
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
                ? Image.asset(widget.backImage, height: 25, width: 25)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: Image.asset(widget.frontImage, height: 25, width: 25),
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

  void _showWinDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Congratulations!"),
        content: const Text("You matched all pairs!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GameState>()._initializeCards(); // Restart the game
            },
            child: const Text("Play Again"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Show win dialog after the UI rebuilds
          if (gameState.isGameWon) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showWinDialog(context);
            });
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: gameState.cards.length,
            itemBuilder: (context, index) {
              final card = gameState.cards[index];
              return FlipCard(
                isFaceUp: card.isFaceUp || card.isMatched,
                frontImage: card.front,
                backImage: card.back,
                onTap: () => gameState.flipCard(index),
              );
            },
          );
        },
      ),
    );
  }
}