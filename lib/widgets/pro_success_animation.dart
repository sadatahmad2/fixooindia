import 'package:flutter/material.dart';
import 'dart:ui';

class ProSuccessAnimation extends StatefulWidget {
  final VoidCallback onFinished;
  const ProSuccessAnimation({super.key, required this.onFinished});

  @override
  State<ProSuccessAnimation> createState() => _ProSuccessAnimationState();
}

class _ProSuccessAnimationState extends State<ProSuccessAnimation> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;
  late Animation<double> _bgScale;
  late Animation<double> _textOpacity;
  late Animation<double> _textScale;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();

    // Cinematic Background Closing (Black circle growing to cover everything)
    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _bgScale = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInQuint),
    );

    // Text reveal animation
    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.2, 0.6, curve: Curves.easeIn)),
    );
    _textScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack)),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.6, 1.0, curve: Curves.easeInOut)),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _bgController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _textController.forward();
    await Future.delayed(const Duration(seconds: 2));
    widget.onFinished();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. The Closing Black Screen (Circle Expansion to Full Black)
          AnimatedBuilder(
            animation: _bgScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScale.value,
                child: Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),

          // 2. The "PREMIUM" Reveal with Cinematic Glow
          AnimatedBuilder(
            animation: _textController,
            builder: (context, child) {
              return Opacity(
                opacity: _textOpacity.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glow Effect
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: _glowOpacity.value,
                          child: Container(
                            width: 250,
                            height: 100,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.5),
                                  blurRadius: 100,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: _textScale.value,
                          child: Column(
                            children: [
                              const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 60),
                              const SizedBox(height: 20),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFEAB0)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 8,
                                    fontFamily: 'Inter', // Assuming standard font
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                'WELCOME TO THE ELITE',
                                style: TextStyle(
                                  color: const Color(0xFFFFD700).withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
