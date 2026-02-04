import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tik_tok_toe/utils/sound_manager.dart';


class HumanGameScreen extends StatefulWidget {
  const HumanGameScreen({super.key});

  @override
  State<HumanGameScreen> createState() => _HumanGameScreenState();
}

class _HumanGameScreenState extends State<HumanGameScreen>
    with TickerProviderStateMixin {
  late List<String> board; // Stores X, O, or empty string
  late String currentPlayer; // X or O
  bool gameOver = false;
  String gameResult = ''; // 'X', 'O', or 'Draw'
  int moveCount = 0;

  late AnimationController _scaleController;
  late Map<int, AnimationController> _cellAnimations;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController.forward();

    // Initialize animation controllers for each cell
    _cellAnimations = {};
    for (int i = 0; i < 9; i++) {
      _cellAnimations[i] = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
    }
  }

  void _initializeGame() {
    board = List<String>.filled(9, '');
    currentPlayer = 'X';
    gameOver = false;
    gameResult = '';
    moveCount = 0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    for (var controller in _cellAnimations.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Check for winner
  String? _checkWinner() {
    const List<List<int>> winningCombinations = [
      [0, 1, 2], // Top row
      [3, 4, 5], // Middle row
      [6, 7, 8], // Bottom row
      [0, 3, 6], // Left column
      [1, 4, 7], // Middle column
      [2, 5, 8], // Right column
      [0, 4, 8], // Diagonal top-left to bottom-right
      [2, 4, 6], // Diagonal top-right to bottom-left
    ];

    for (var combination in winningCombinations) {
      if (board[combination[0]].isNotEmpty &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        return board[combination[0]];
      }
    }
    return null;
  }

  // Handle cell tap
 void _onCellTap(int index) {
  if (gameOver || board[index].isNotEmpty) return;

  SoundManager.tap(); // 🔊 move sound


    setState(() {
      board[index] = currentPlayer;
      moveCount++;

      // Check for winner
      String? winner = _checkWinner();
      if (winner != null) {
        gameOver = true;
        gameResult = winner;
        _showResultPopup('$winner wins!', 'Player $winner has won the game!');
        return;
      }

      // Check for draw
      if (moveCount == 9) {
        gameOver = true;
        gameResult = 'Draw';
        _showResultPopup('It\'s a Draw!', 'The game ended in a tie.');
        return;
      }

      // Switch player
      currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
    });

    // Animate the cell
    _cellAnimations[index]?.forward();
  }

 void _showResultPopup(String title, String message) {
  if (gameResult == 'Draw') {
    SoundManager.notify(); // 🔔 draw
  } else {
    SoundManager.win(); // 🏆 win
  }

  showDialog(

      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameResultPopup(
          title: title,
          message: message,
          onPlayAgain: () {
            Navigator.pop(context);
            setState(() {
              _initializeGame();
            });
            // Reset all cell animations
            for (var controller in _cellAnimations.values) {
              controller.reset();
            }
          },
          onHome: () {
            Navigator.pop(context);
            Navigator.pop(context); // Go back to home screen
          },
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
    });
    // Reset all cell animations
    for (var controller in _cellAnimations.values) {
      controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button - show confirmation or just return
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1A2F),
        body: SafeArea(
          child: Stack(
            children: [
              // Background gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.5,
                      colors: [
                        const Color(0xFF1E3A5F).withOpacity(0.3),
                        const Color(0xFF0A1A2F),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () {
  SoundManager.click(); // 🔊 back click
  Navigator.pop(context);
},
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white10,
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),

                        // Title
                        Text(
                          'TWO PLAYER',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),

                        // Reset button
                        GestureDetector(
                          onTap: () {
  SoundManager.click(); // 🔊 reset click
  _resetGame();
},
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white10,
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Player indicator
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _scaleController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Current Player',
                          style: GoogleFonts.fredoka(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white60,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: currentPlayer == 'X'
                                  ? [
                                      Colors.blue.shade600,
                                      Colors.blue.shade400,
                                    ]
                                  : [
                                      Colors.purple.shade600,
                                      Colors.purple.shade400,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (currentPlayer == 'X'
                                        ? Colors.blue
                                        : Colors.purple)
                                    .withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Text(
                            'Player ${currentPlayer == 'X' ? '1 (X)' : '2 (O)'}',
                            style: GoogleFonts.fredoka(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Game board
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _scaleController,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            return ScaleTransition(
                              scale: Tween<double>(begin: 0.6, end: 1.0)
                                  .animate(
                                CurvedAnimation(
                                  parent: _cellAnimations[index]!,
                                  curve: Curves.elasticOut,
                                ),
                              ),
                              child: _buildGameCell(index),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Move counter
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      'Moves: $moveCount / 9',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white60,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCell(int index) {
    return GestureDetector(
      onTap: () => _onCellTap(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A3A52).withOpacity(0.8),
              const Color(0xFF0F2847).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white10,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onCellTap(index),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: board[index].isEmpty
                    ? const SizedBox.shrink()
                    : Container(
                        key: ValueKey<String>(board[index]),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: board[index] == 'X'
                              ? LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.purple.shade400,
                                    Colors.purple.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: (board[index] == 'X'
                                      ? Colors.blue
                                      : Colors.purple)
                                  .withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            board[index],
                            style: GoogleFonts.fredoka(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Game Result Popup
class GameResultPopup extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameResultPopup({
    super.key,
    required this.title,
    required this.message,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  State<GameResultPopup> createState() => _GameResultPopupState();
}

class _GameResultPopupState extends State<GameResultPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.forward();
    _confettiController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti particles (optional decoration)
            ...List.generate(
              12,
              (index) => Positioned(
                left: 50 + (index * 20).toDouble(),
                top: -20,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                      parent: _confettiController,
                      curve: Curves.easeInQuad,
                    ),
                  ),
                  child: Opacity(
                    opacity: _confettiController.value > 0.7 ? 0 : 1,
                    child: Transform.rotate(
                      angle: (index * 0.5),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: [Colors.blue, Colors.purple, Colors.green]
                              [index % 3],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main dialog
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF0F2847),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white12,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade400,
                            Colors.amber.shade600,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      widget.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Message
                    Text(
                      widget.message,
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Buttons
                    Column(
                      children: [
                        // Play Again button
                        GestureDetector(
                          onTap: () {
  SoundManager.click(); // 🔊 click
  widget.onPlayAgain();
},
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade600,
                                  Colors.green.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
  SoundManager.click(); // 🔊 click
  widget.onPlayAgain();
},
                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Text(
                                    'Play Again',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Home button
                        GestureDetector(
                          onTap: () {
  SoundManager.click(); // 🔊 click
  widget.onHome();
},

                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white30,
                                width: 2,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
  SoundManager.click(); // 🔊 click
  widget.onHome();
},

                                borderRadius: BorderRadius.circular(14),
                                child: Center(
                                  child: Text(
                                    'Home',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}