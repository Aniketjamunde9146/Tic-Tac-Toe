import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tik_tok_toe/screens/ai_game_screen.dart';
import 'package:tik_tok_toe/screens/human_game_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tik_tok_toe/utils/sound_manager.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _buttonHoverController;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _buttonHoverController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _buttonHoverController.dispose();
    super.dispose();
  }

 void _showGameRulesPopup({required bool isAI}) {
  SoundManager.pop(); // 🔊 popup sound

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return GameRulesPopup(
        onStartGame: () {
          Navigator.pop(context);

          SoundManager.gameStart(); // 🔊 game start sound

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  isAI ? const AIGameScreen() : const HumanGameScreen(),
            ),
          );
        },
      );
    },
  );
}


  void _toggleMute() {
  setState(() {
    _isMuted = !_isMuted;
    SoundManager.isMuted = _isMuted; // 🔊 link sound system
  });
}

  Future<void> _openLink(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open link')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: SafeArea(
        child: Stack(
          children: [
            // Enhanced background with multiple gradients
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0A1A2F),
                      const Color(0xFF1a3a52),
                      const Color(0xFF0A1A2F),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Animated background orbs
            Positioned(
              top: -150,
              right: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.blue.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -120,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple.withOpacity(0.08),
                      Colors.purple.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top bar with mute button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Colors.blue[300]!, Colors.cyan[300]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'TIC TAC TOE',
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleMute,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isMuted
                                    ? [
                                        Colors.grey.withOpacity(0.6),
                                        Colors.grey.withOpacity(0.4)
                                      ]
                                    : [
                                        Colors.blue.withOpacity(0.6),
                                        Colors.cyan.withOpacity(0.4)
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isMuted
                                      ? Colors.grey.withOpacity(0.4)
                                      : Colors.blue.withOpacity(0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isMuted ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Logo and Main Title
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                      CurvedAnimation(
                        parent: _scaleController,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Logo with premium glow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.6),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.3),
                                blurRadius: 60,
                                spreadRadius: 12,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image(
                              image: const AssetImage('assets/logo.jpeg'),
                              height: 110,
                              width: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Colors.blue[200]!, Colors.cyan[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'TIC TAC TOE',
                            style: GoogleFonts.fredoka(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Challenge Yourself',
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Game Mode Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        _buildGameButton(
                          title: 'Play Two Players',
                          subtitle: 'Challenge a friend',
                          color: Colors.blue,
                          delay: 0.1,
                          onTap: () {
  SoundManager.click(); // 🔊 button click
  _showGameRulesPopup(isAI: false);
},

                        ),

                        const SizedBox(height: 18),
                        _buildGameButton(
                          title: 'Play With AI',
                          subtitle: 'Play vs AI',
                          color: Colors.purple,
                          delay: 0.2,
                          onTap: () {
  SoundManager.click(); // 🔊 button click
  _showGameRulesPopup(isAI: true);
},

                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Column(
  children: [
    Divider(
      color: Colors.white.withOpacity(0.2),
      thickness: 1,
      indent: 60,
      endIndent: 60,
    ),
    const SizedBox(height: 14),

    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(
          icon: Icons.phone_callback,
          color: Colors.green,
          onTap: () {
  SoundManager.click(); // 🔊 tap sound
  _openLink('https://wa.me/+919146293702');
},

        ),
        const SizedBox(width: 18),
        _socialButton(
          icon: Icons.camera_alt,
          color: Colors.pink,
         onTap: () {
  SoundManager.click();
  _openLink('https://instagram.com/aniket_jamunde_002');
},

        ),
        const SizedBox(width: 18),
        _socialButton(
          icon: Icons.code,
          color: Colors.blueAccent,
         onTap: () {
  SoundManager.click();
  _openLink('https://aniketwebdev.netlify.app/');
},

        ),
      ],
    ),

    const SizedBox(height: 10),
    Text(
      'Made with ❤️ by Aniket',
      style: GoogleFonts.fredoka(
        fontSize: 12,
        color: Colors.white54,
      ),
    ),
  ],
),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _socialButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}

  Widget _buildGameButton({
    required String title,
    required String subtitle,
    required Color color,
    required double delay,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _scaleController,
              curve: Interval(delay, delay + 0.4, curve: Curves.easeOut),
            ),
          ),
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: isDisabled
                  ? [color.withOpacity(0.3), color.withOpacity(0.2)]
                  : [color.withOpacity(0.9), color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.fredoka(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.fredoka(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    if (!isDisabled)
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      )
                    else
                      Icon(
                        Icons.lock_outline,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Game Rules Popup Widget - Enhanced
class GameRulesPopup extends StatefulWidget {
  final VoidCallback onStartGame;

  const GameRulesPopup({super.key, required this.onStartGame});

  @override
  State<GameRulesPopup> createState() => _GameRulesPopupState();
}

class _GameRulesPopupState extends State<GameRulesPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F2847),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 50,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade500, Colors.blue.shade700],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Game Rules',
                  style: GoogleFonts.fredoka(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),

                // Rules content
                SizedBox(
                  height: 280,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRuleItem(
                          icon: Icons.grid_3x3,
                          title: 'The Board',
                          description:
                              'The game is played on a 3×3 grid. Players take turns marking empty squares.',
                          iconColor: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        _buildRuleItem(
                          icon: Icons.person,
                          title: 'Symbols',
                          description:
                              'Player 1 uses X, Player 2 uses O. Player 1 always goes first.',
                          iconColor: Colors.cyan,
                        ),
                        const SizedBox(height: 20),
                        _buildRuleItem(
                          icon: Icons.flag,
                          title: 'Victory',
                          description:
                              'Get three of your symbols in a row (horizontally, vertically, or diagonally).',
                          iconColor: Colors.green,
                        ),
                        const SizedBox(height: 20),
                        _buildRuleItem(
                          icon: Icons.handshake,
                          title: 'Draw',
                          description:
                              'If all 9 squares are filled with no winner, it\'s a draw.',
                          iconColor: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                       onTap: () {
  SoundManager.click(); // 🔊 back tap
  Navigator.pop(context);
},

                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                            onTap: () {
  SoundManager.click(); // 🔊 back tap
  Navigator.pop(context);
},

                              borderRadius: BorderRadius.circular(14),
                              child: Center(
                                child: Text(
                                  'Back',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                       onTap: () {
  SoundManager.gameStart(); // 🔊 start sound
  widget.onStartGame();
},

                        child: Container(
                          height: 56,
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
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                             onTap: () {
  SoundManager.gameStart(); // 🔊 start sound
  widget.onStartGame();
},

                              borderRadius: BorderRadius.circular(14),
                              child: Center(
                                child: Text(
                                  'Start Game',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
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
      ),
    );
  }

  Widget _buildRuleItem({
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [iconColor.withOpacity(0.8), iconColor.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.fredoka(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.75),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
