import 'dart:io'; // for InternetAddress + SocketException
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/manager_home/manager_home.dart';
import 'package:final_year_project/customer_home/customer_home.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with TickerProviderStateMixin {
  late final AnimationController _master; // drives staggered images + texts
  late final AnimationController _panelCtrl; // drives bottom panel slide
  late final AnimationController _decorCtrl; // NEW: background floating boxes

  // Panel slide up
  late final Animation<Offset> _panelSlide;

  // Buttons fade/scale
  late final Animation<double> _btn1Fade;
  late final Animation<double> _btn1Scale;
  late final Animation<double> _btn2Fade;
  late final Animation<double> _btn2Scale;

  // Six image tile animations (staggered)
  final int _tileCount = 6;
  late final List<Animation<double>> _tileFades;
  late final List<Animation<double>> _tileScales;

  // Tap pulse animations for each tile (real-time on user tap)
  late final List<AnimationController> _tapCtrls;
  late final List<Animation<double>> _tapScales;

  final supabase = Supabase.instance.client;

  // 1-second loading flags for buttons
  bool _loadingManager = false;
  bool _loadingPassenger = false;

  // Editable placeholders for your images (provide 6)
  final List<String> imageAssets = const [
    'assets/bus/bus1.jpg',
    'assets/van/van1.jpeg',
    'assets/bus/bus2.jpg',
    'assets/van/van2.jpg',
    'assets/bus/bus3.jpg',
    'assets/van/van3.jpg',
  ];

  @override
  void initState() {
    super.initState();

    // Master controller for staggered elements (images + buttons)
    _master = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // Bottom panel slide-up
    _panelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _panelSlide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _panelCtrl, curve: Curves.easeOutCubic));

    // Buttons animation intervals (within master timeline)
    _btn1Fade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
    );
    _btn1Scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
      ),
    );
    _btn2Fade = CurvedAnimation(
      parent: _master,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );
    _btn2Scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _master,
        curve: const Interval(0.70, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Stagger for each image tile
    _tileFades = List.generate(_tileCount, (i) {
      final start = 0.05 + i * 0.07;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _master,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });
    _tileScales = List.generate(_tileCount, (i) {
      final start = 0.05 + i * 0.07;
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: _master,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    // NEW: per-tile tap controllers for press pulse (1.0 -> 0.95 -> 1.0)
    _tapCtrls = List.generate(
      _tileCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 140),
        reverseDuration: const Duration(milliseconds: 140),
      ),
    );
    _tapScales = _tapCtrls
        .map(
          (c) => Tween<double>(
            begin: 1.0,
            end: 0.95,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(c),
        )
        .toList();

    // NEW: Background decor controller (floating boxes)
    _decorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _master.dispose();
    _panelCtrl.dispose();
    _decorCtrl.dispose();
    for (final c in _tapCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  // ====== Minimal additions below for connectivity + back blocking ======

  Future<bool> _hasInternet() async {
    try {
      final res = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _looksLikeNetworkError(dynamic e) {
    if (e is SocketException) return true;
    final m = e.toString().toLowerCase();
    return m.contains('network') ||
        m.contains('host lookup') ||
        m.contains('failed host lookup') ||
        m.contains('socket') ||
        m.contains('timed out') ||
        m.contains('xmlhttprequest') ||
        m.contains('failed to fetch');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // Handle button press: show 1s loading, then proceed
  Future<void> _onRolePressed(String role) async {
    if (!mounted) return;
    setState(() {
      if (role == 'manager') {
        _loadingManager = true;
      } else {
        _loadingPassenger = true;
      }
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      if (role == 'manager') {
        _loadingManager = false;
      } else {
        _loadingPassenger = false;
      }
    });

    // Proceed with existing logic (network check, role update, navigation)
    _selectRoleAndGo(role);
  }

  // Store chosen role (unchanged) + DIRECT NAVIGATION (no popups)
  Future<void> _selectRoleAndGo(String role) async {
    // Block if offline
    if (!await _hasInternet()) {
      _showSnack("No internet connection. Please check your network.");
      return;
    }

    // Upsert role to ensure the row exists (handles users created before trigger)
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'email': user.email?.toLowerCase(),
          'role': role.toLowerCase().trim(),
          'updated_at': DateTime.now().toIso8601String(),
        }).select();
      }
    } catch (e) {
      if (_looksLikeNetworkError(e)) {
        _showSnack("No internet connection. Please check your network.");
        return; // do not proceed if network is down
      } else {
        debugPrint('Role upsert failed (non-network): $e');
      }
    }

    // DIRECT NAVIGATION (no dialog)
    if (!mounted) return;
    if (role == 'manager') {
      Navigator.of(
        context,
      ).pushAndRemoveUntil(_route(const ManagerHome()), (r) => false);
    } else {
      Navigator.of(
        context,
      ).pushAndRemoveUntil(_route(const CustomerHome()), (r) => false);
    }
  }

  // Smooth transition route (updated)
  PageRoute _route(Widget page) => PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 480),
    reverseTransitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (context, anim, sec, child) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      // Subtle fade + slight slide + tiny scale for smoother feel
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(curved);
      final scale = Tween<double>(begin: 0.98, end: 1.0).animate(curved);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );

  // Trigger the tap pulse for a tile
  Future<void> _onTileTap(int index) async {
    try {
      await _tapCtrls[index].forward();
    } finally {
      if (mounted) {
        await _tapCtrls[index].reverse();
      }
    }
  }

  // Tile widget with rounded corners and placeholder image
  Widget _imageTile(int index) {
    final fade = _tileFades[index];
    final scale = _tileScales[index];
    final cs = Theme.of(context).colorScheme;

    return FadeTransition(
      opacity: fade,
      child: ScaleTransition(
        scale: scale, // initial stagger scale
        child: ScaleTransition(
          scale: _tapScales[index], // real-time tap pulse
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onTileTap(index),
                splashColor: cs.onSurface.withOpacity(0.08),
                highlightColor: Colors.transparent,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    color: cs.surface, // fallback color
                    foregroundDecoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(imageAssets[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: imageAssets[index].isEmpty
                        ? Center(
                            child: Icon(
                              Icons.image,
                              size: 36,
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Optional subtle gradient bg
  LinearGradient _animatedGradient(double t, Color bg) {
    final phase = (math.sin(t * 2 * math.pi) + 1) / 2;
    return LinearGradient(
      begin: Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, phase)!,
      end: Alignment.lerp(Alignment.bottomRight, Alignment.topLeft, phase)!,
      colors: [bg, bg],
    );
  }

  // NEW: Animated background floating boxes painter
  Widget _animatedBoxes(Color color) {
    return AnimatedBuilder(
      animation: _decorCtrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _BoxesPainter(_decorCtrl.value, color),
          size: Size.infinite,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      // block system back
      onWillPop: () async => false,
      child: AnimatedBuilder(
        animation: _master,
        builder: (context, _) {
          return Scaffold(
            backgroundColor: cs.background,
            body: Stack(
              children: [
                // Background gradient + floating boxes
                Container(
                  decoration: BoxDecoration(
                    gradient: _animatedGradient(0, cs.background),
                  ),
                ),
                IgnorePointer(child: _animatedBoxes(cs.onBackground)),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        // 2-column grid of 6 rounded images
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _tileCount,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (_, i) => _imageTile(i),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // Bottom green panel slides up
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _panelSlide,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Manager button
                            FadeTransition(
                              opacity: _btn1Fade,
                              child: ScaleTransition(
                                scale: _btn1Scale,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loadingManager
                                        ? null
                                        : () => _onRolePressed('manager'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cs.secondary,
                                      foregroundColor: cs.onSecondary,
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: _loadingManager
                                        ? SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    cs.onSecondary,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            "Sign Up as a Manager",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Guest button
                            FadeTransition(
                              opacity: _btn2Fade,
                              child: ScaleTransition(
                                scale: _btn2Scale,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loadingPassenger
                                        ? null
                                        : () => _onRolePressed('passenger'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: cs.secondary,
                                      foregroundColor: cs.onSecondary,
                                      minimumSize: const Size.fromHeight(50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                    child: _loadingPassenger
                                        ? SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    cs.onSecondary,
                                                  ),
                                            ),
                                          )
                                        : const Text(
                                            "Sign Up as a Passenger",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Blurb
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "- Explore the YouBook services.\n- Add your service.\n- Book your favorite service.",
                                style: TextStyle(
                                  color: cs.onPrimary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Painter for floating boxes background
class _BoxesPainter extends CustomPainter {
  _BoxesPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // Draw a few animated rounded boxes
    final boxes = <RRect>[];
    for (int i = 0; i < 5; i++) {
      final phase = (t + i * 0.2) % 1.0;
      final width = size.width * (0.18 + (i % 3) * 0.03);
      final height = width * 0.6;
      final x = (size.width * (0.1 + (i * 0.2))) % (size.width - width);
      final y = size.height * (1.0 - phase) - height; // float upwards
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, width, height),
        const Radius.circular(16),
      );
      boxes.add(rect);
    }

    for (final r in boxes) {
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoxesPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.color != color;
}
