import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/space_logo.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';
import '../data/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    // Elegant automatic transition to authenticate or dashboard
    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        final hasSession = AuthService.isLoggedIn();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                hasSession ? const DashboardScreen() : const AuthScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0A09), // stone-950
      body: Stack(
        children: [
          // Elegant glow effect
          Center(
            child: Container(
              key: const ValueKey('glow-circle'),
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC5A153).withValues(alpha: 0.04),
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpaceLogo(size: 88.0),
                  const SizedBox(height: 32),
                  const Text(
                    "S'PACE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w100,
                      letterSpacing: 10.0,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 1,
                    color: const Color(0xFFC5A153).withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "IMMOSPACE",
                    style: TextStyle(
                      color: Color(0xFFC5A153),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      "L'immobilier haut de gamme autrement.\nVisite 360° & simulateur Réalité Augmentée.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFA8A29E), // stone-400
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Aesthetic progress line indicator
                  SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        backgroundColor: Color(0xFF1C1917),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFC5A153)),
                        minHeight: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Préparation de votre espace immersif...",
                    style: TextStyle(
                      color: Color(0xFF78716C), // stone-500
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom alignment credentials
          const Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PARIS • NEUILLY • LYON",
                  style: TextStyle(
                    color: Color(0xFF44403C), // stone-700
                    fontSize: 8,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "S'PACE IMMERSION © 2026",
                  style: TextStyle(
                    color: Color(0xFF44403C),
                    fontSize: 8,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
