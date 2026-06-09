import 'package:flutter/material.dart';

class SpaceLogo extends StatefulWidget {
  final double size;

  const SpaceLogo({
    super.key,
    this.size = 64.0,
  });

  @override
  State<SpaceLogo> createState() => _SpaceLogoState();
}

class _SpaceLogoState extends State<SpaceLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Lance l'animation dès que le widget est inséré dans l'arbre
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        padding: EdgeInsets.all(widget.size * 0.12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1917), // stone-900
          borderRadius: BorderRadius.circular(widget.size * 0.25),
          border: Border.all(
            color: const Color(0xFFC5A153)
                .withValues(alpha: 0.3), // Gold with opacity
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFC5A153).withValues(alpha: 0.06),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Gradient effect inside logo
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.size * 0.15),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      const Color(0xFFC5A153).withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Image du logo depuis les assets
            Center(
              child: Image.asset(
                'assets/Group 1.png',
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
