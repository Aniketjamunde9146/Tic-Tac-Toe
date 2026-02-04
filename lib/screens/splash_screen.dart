import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tik_tok_toe/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotate;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade out animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation for logo
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Rotation animation for logo
    _logoRotate = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Fade animation for whole screen
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInCubic),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _logoController.forward();
    _pulseController.repeat(reverse: true);

    // Navigate after delay
    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        _fadeController.forward().then((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2F),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Animated gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0A1A2F),
                    const Color(0xFF1a2a45),
                    const Color(0xFF0F2340),
                  ],
                ),
              ),
            ),

            // Animated background circles (decorative)
            Positioned(
              top: -100,
              right: -100,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.blue.withOpacity(0.15),
                        Colors.blue.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -80,
              left: -80,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purple.withOpacity(0.12),
                        Colors.purple.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Logo
                  ScaleTransition(
                    scale: _logoScale,
                    child: RotationTransition(
                      turns: _logoRotate,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.2),
                              blurRadius: 60,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                        child: Image(
                          image: const AssetImage('assets/logo.jpeg'),
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.blue[200]!,
                        Colors.blue[400]!,
                        Colors.cyan[300]!,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
  'TIC TAC TOE',
  style: GoogleFonts.fredoka(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 3,
  ),
),

                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
  'Master the Game',
  style: GoogleFonts.fredoka(
    fontSize: 14,
    color: Colors.white.withOpacity(0.7),
    letterSpacing: 2,
    fontStyle: FontStyle.italic,
  ),
),


                  const SizedBox(height: 60),

                  // Custom animated loader
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating outer ring
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _logoController,
                              curve: Curves.linear,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.4),
                                width: 3,
                              ),
                            ),
                          ),
                        ),

                        // Second rotating ring (reversed)
                        RotationTransition(
                          turns: Tween(begin: 1.0, end: 0.0).animate(
                            CurvedAnimation(
                              parent: _logoController,
                              curve: Curves.linear,
                            ),
                          ),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.cyan.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        // Center glowing dot
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Colors.blue[300]!, Colors.cyan],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Loading text
                  Text(
  'Loading...',
  style: GoogleFonts.fredoka(
    fontSize: 12,
    color: Colors.white.withOpacity(0.6),
    letterSpacing: 2,
    fontWeight: FontWeight.w500,
  ),
),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}