# Card Matching Game

A simple card-matching memory game built with Flutter and Provider for state management. The game challenges players to match pairs of cards by flipping them over.

## Features
- Flip animation with smooth transitions.
- Randomized card layout for each game.
- State management using Provider.
- Win condition detection with a congratulatory dialog.
- Easy-to-use UI with a 4x4 grid layout.

## Installation
### Prerequisites
- Flutter SDK installed
- Dart installed
- A code editor (VS Code, Android Studio, etc.)

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/card-matching-game.git
   ```
2. Navigate to the project directory:
   ```bash
   cd card-matching-game
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## How to Play
1. Tap a card to flip it over.
2. Tap another card to try and find its matching pair.
3. If the cards match, they stay face-up; otherwise, they flip back after a second.
4. Match all pairs to win the game!

## Project Structure
```
lib/
├── main.dart          # Entry point of the app
├── game_state.dart    # Game logic and state management
├── card_model.dart    # Card data model
├── flip_card.dart     # Flip animation widget
├── home_page.dart     # UI layout with grid of cards
assets/
├── images/           # Card images
├── screenshots/      # Screenshots for documentation
```

## Dependencies
- `flutter`
- `provider`