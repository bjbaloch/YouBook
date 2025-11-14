/// Welcome UI - Welcome page with animations
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:final_year_project/core/theme/app_colors.dart';
import 'package:final_year_project/user_selection/user_selection.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _introController;
  late final AnimationController _bgController;
  late final AnimationController _loadingController;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _logoGlowAnim;
  late final Animation<double> _welcomeOpacity;
  late final Animation<Offset> _welcomeOffset;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _buttonScale;

  final GlobalKey _stackKey = GlobalKey();
  final List<_TouchRipple> _ripples = [];

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Pulsing logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _logoGlowAnim = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Intro animations
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _welcomeOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
    );
    _welcomeOffset =
        Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
          ),
        );

    _buttonOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _buttonScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Animated background
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 3-second progress animation
    _loadingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              _progress = _loadingController.value * 100;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
              );
            }
          });

    // Start loading animation after intro
    Future.delayed(const Duration(milliseconds: 1500), () {
      _loadingController.forward();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _introController.dispose();
    _bgController.dispose();
    _loadingController.dispose();
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  LinearGradient _animatedGradient(double t) {
    final phase = (math.sin(t * 2 * math.pi) + 1) / 2;
    return LinearGradient(
      begin: Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, phase)!,
      end: Alignment.lerp(Alignment.bottomRight, Alignment.topLeft, phase)!,
      colors: const [AppColors.lightSeaGreen, AppColors.primaryGreenDark],
    );
  }

  Widget _animatedLetter({
    required String char,
    required Color color,
    required int index,
  }) {
    final double start = 0.40 + index * 0.07;
    final double end = (start + 0.30).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );
    return ScaleTransition(
      scale: Tween<double>(begin: 0.6, end: 1.0).animate(anim),
      child: FadeTransition(
        opacity: anim,
        child: Text(
          char,
          style: TextStyle(
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _spawnRipple(Offset globalPos) {
    final box = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(globalPos);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    late final _TouchRipple ripple;
    ripple = _TouchRipple(position: local, controller: controller);

    controller.addListener(() => setState(() {}));
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        setState(() {
          _ripples.remove(ripple);
        });
      }
    });

    setState(() {
      _ripples.add(ripple);
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.lightSeaGreen,
          body: Stack(
            key: _stackKey,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: _animatedGradient(_bgController.value),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo animation
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: AnimatedBuilder(
                            animation: _logoGlowAnim,
                            builder: (context, child) {
                              return Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.dangerRed,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.25),
                                      blurRadius: 6 + _logoGlowAnim.value,
                                      spreadRadius:
                                          1 + (_logoGlowAnim.value / 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    "assets/yb_logo.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Welcome text
                        SlideTransition(
                          position: _welcomeOffset,
                          child: FadeTransition(
                            opacity: _welcomeOpacity,
                            child: const Text(
                              "Welcome to online\nBooking Platform",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: AppColors.textWhite,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // YOUBOOK.com
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _animatedLetter(
                              char: "Y",
                              color: AppColors.textWhite,
                              index: 0,
                            ),
                            _animatedLetter(
                              char: "O",
                              color: AppColors.logoYellow,
                              index: 1,
                            ),
                            _animatedLetter(
                              char: "U",
                              color: AppColors.textWhite,
                              index: 2,
                            ),
                            _animatedLetter(
                              char: "B",
                              color: AppColors.textWhite,
                              index: 3,
                            ),
                            _animatedLetter(
                              char: "O",
                              color: AppColors.logoYellow,
                              index: 4,
                            ),
                            _animatedLetter(
                              char: "O",
                              color: AppColors.logoYellow,
                              index: 5,
                            ),
                            _animatedLetter(
                              char: "K",
                              color: AppColors.textWhite,
                              index: 6,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 1.0),
                              child: _animatedLetter(
                                char: ".com",
                                color: AppColors.textWhite,
                                index: 7,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 180),

                        // Attractive progress area
                        FadeTransition(
                          opacity: _buttonOpacity,
                          child: ScaleTransition(
                            scale: _buttonScale,
                            child: SizedBox(
                              width: 220,
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: LinearProgressIndicator(
                                      value: _progress / 100,
                                      minHeight: 10,
                                      backgroundColor: Colors.white24,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            AppColors.accentOrange,
                                          ),
                                    ),
                                  ),
                                  // Bus icon moving along the bar
                                  AnimatedBuilder(
                                    animation: _loadingController,
                                    builder: (context, _) {
                                      return Positioned(
                                        left: (_loadingController.value * 200)
                                            .clamp(0, 200),
                                        top: -6,
                                        child: Transform.rotate(
                                          angle: 0,
                                          child: const Icon(
                                            Icons.directions_bus_rounded,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Text(
                          "${_progress.toInt()}%",
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Ripple painter overlay
              IgnorePointer(
                ignoring: true,
                child: CustomPaint(
                  painter: _RipplePainter(_ripples),
                  size: Size.infinite,
                ),
              ),

              // Tap ripple effect
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (e) => _spawnRipple(e.position),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Ripple helpers
class _TouchRipple {
  _TouchRipple({required this.position, required this.controller});
  final Offset position;
  final AnimationController controller;
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.ripples);
  final List<_TouchRipple> ripples;

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in ripples) {
      final t = r.controller.value;
      final radius = (size.longestSide * 0.28) * t;
      final fill = Paint()
        ..color = Colors.white.withOpacity(0.08 * (1 - t))
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = Colors.white.withOpacity(0.25 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(r.position, radius, fill);
      canvas.drawCircle(r.position, radius, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) =>
      oldDelegate.ripples != ripples;
}

