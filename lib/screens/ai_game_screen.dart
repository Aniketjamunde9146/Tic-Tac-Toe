import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:tik_tok_toe/utils/sound_manager.dart';


class AIGameScreen extends StatefulWidget {
  const AIGameScreen({super.key});

  @override
  State<AIGameScreen> createState() => _AIGameScreenState();
}

class _AIGameScreenState extends State<AIGameScreen>
    with TickerProviderStateMixin {
  late List<String> board; // Stores X (player), O (AI), or empty string
  late String currentPlayer; // X or O
  bool gameOver = false;
  String gameResult = ''; // 'X', 'O', or 'Draw'
  int moveCount = 0;
  bool isAIThinking = false;

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
    isAIThinking = false;
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
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
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

  // Get empty cells
  List<int> _getEmptyCells() {
    List<int> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        emptyCells.add(i);
      }
    }
    return emptyCells;
  }

  // Minimax algorithm for AI
  int _minimax(List<String> board, int depth, bool isMaximizing) {
    String? winner = _checkWinnerForBoard(board);

    if (winner == 'O') {
      return 10 - depth; // AI wins
    } else if (winner == 'X') {
      return depth - 10; // Player wins
    }

    if (_getEmptyCellsForBoard(board).isEmpty) {
      return 0; // Draw
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i in _getEmptyCellsForBoard(board)) {
        board[i] = 'O';
        int score = _minimax(board, depth + 1, false);
        board[i] = '';
        bestScore = max(bestScore, score);
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i in _getEmptyCellsForBoard(board)) {
        board[i] = 'X';
        int score = _minimax(board, depth + 1, true);
        board[i] = '';
        bestScore = min(bestScore, score);
      }
      return bestScore;
    }
  }

  String? _checkWinnerForBoard(List<String> board) {
    const List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
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

  List<int> _getEmptyCellsForBoard(List<String> board) {
    List<int> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        emptyCells.add(i);
      }
    }
    return emptyCells;
  }

  // AI finds best move
  int _getAIMove() {
    int bestScore = -1000;
    int bestMove = 0;

    for (int i in _getEmptyCells()) {
      board[i] = 'O';
      int score = _minimax(board, 0, false);
      board[i] = '';

      if (score > bestScore) {
        bestScore = score;
        bestMove = i;
      }
    }

    return bestMove;
  }

  // Handle player move
 void _onCellTap(int index) {
  if (gameOver || board[index].isNotEmpty || isAIThinking) return;

  SoundManager.tap(); // 🔊 player move sound


    setState(() {
      board[index] = 'X';
      moveCount++;

      // Check for winner
      String? winner = _checkWinner();
      if (winner != null) {
        gameOver = true;
        gameResult = winner;
        _showResultPopup(
          'You Win!',
          'Congratulations! You defeated the AI!',
          isPlayerWin: true,
        );
        return;
      }

      // Check for draw
      if (moveCount == 9) {
        gameOver = true;
        gameResult = 'Draw';
        _showResultPopup(
          'It\'s a Draw!',
          'The game ended in a tie with the AI.',
          isPlayerWin: false,
        );
        return;
      }

      currentPlayer = 'O';
      isAIThinking = true;
    });

    _cellAnimations[index]?.forward();

    // AI move after a delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!gameOver) {
        _makeAIMove();
      }
    });
  }

  void _makeAIMove() {
    if (gameOver) return;

    int aiMoveIndex = _getAIMove();

    setState(() {
  board[aiMoveIndex] = 'O';
  moveCount++;

  SoundManager.tap(); // 🔊 AI move sound


      // Check for winner
      String? winner = _checkWinner();
      if (winner != null) {
        gameOver = true;
        gameResult = winner;
        _showResultPopup(
          'AI Wins!',
          'The AI has defeated you. Try again!',
          isPlayerWin: false,
        );
        return;
      }

      // Check for draw
      if (moveCount == 9) {
        gameOver = true;
        gameResult = 'Draw';
        _showResultPopup(
          'It\'s a Draw!',
          'The game ended in a tie with the AI.',
          isPlayerWin: false,
        );
        return;
      }

      currentPlayer = 'X';
      isAIThinking = false;
    });

    _cellAnimations[aiMoveIndex]?.forward();
  }

  void _showResultPopup(
  String title,
  String message, {
  required bool isPlayerWin,
}) {
  if (isPlayerWin) {
    SoundManager.win(); // 🏆 player win
  } else {
    SoundManager.notify(); // ❌ lose OR draw
  }

  showDialog(

      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameResultPopup(
          title: title,
          message: message,
          isPlayerWin: isPlayerWin,
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
                          'VS AI',
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
                        if (!isAIThinking)
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
                              currentPlayer == 'X' ? 'Your Turn' : 'AI Turn',
                              style: GoogleFonts.fredoka(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.orange.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'AI Thinking...',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
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

// Game Result Popup for AI
class GameResultPopup extends StatefulWidget {
  final String title;
  final String message;
  final bool isPlayerWin;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameResultPopup({
    super.key,
    required this.title,
    required this.message,
    required this.isPlayerWin,
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
    if (widget.isPlayerWin) {
      _confettiController.repeat();
    }
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
            // Confetti particles (only for player win)
            if (widget.isPlayerWin)
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
                    // Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: widget.isPlayerWin
                              ? [
                                  Colors.amber.shade400,
                                  Colors.amber.shade600,
                                ]
                              : [
                                  Colors.red.shade400,
                                  Colors.red.shade600,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.isPlayerWin
                                    ? Colors.amber
                                    : Colors.red)
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isPlayerWin
                            ? Icons.emoji_events
                            : Icons.sentiment_dissatisfied,
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