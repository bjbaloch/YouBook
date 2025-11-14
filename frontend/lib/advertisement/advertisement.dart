import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({
    super.key,
    required this.ads, // optional captions (kept for compatibility)
    this.height = 200,
    this.cardWidth = 550,
    this.outerMargin = 0,
    this.gap = 10,
    this.autoScrollInterval = const Duration(seconds: 3),
    this.scrollDuration = const Duration(milliseconds: 500), // a bit smoother
    this.bucketName = 'advertisement', // Supabase Storage bucket name
    this.folderPath = '', // optional folder inside the bucket
    this.maxCards = 3, // exactly 3 auto-scrollable cards
  });

  // Optional captions to overlay (not required, but kept to avoid breaking callers)
  final List<String> ads;

  // Layout
  final double height;
  final double cardWidth;
  final double outerMargin;
  final double gap;

  // Auto-scroll
  final Duration autoScrollInterval;
  final Duration scrollDuration;

  // Supabase storage config
  final String bucketName;
  final String folderPath;

  // Count of cards to display
  final int maxCards;

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  PageController? _ctrl;
  Timer? _timer;
  double? _lastViewportWidth;

  // Using Supabase already initialized in main.dart
  SupabaseClient get _sb => Supabase.instance.client;

  // Image URLs to render (public or signed)
  List<String> _imageUrls = [];

  // Track active dot
  int _activeIndex = 0;

  int get _len => (_imageUrls.isNotEmpty ? _imageUrls.length : widget.maxCards);

  @override
  void initState() {
    super.initState();
    _loadImagesFromSupabase().whenComplete(() {
      // prepare base page after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetLoopBase());
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl?.dispose();
    super.dispose();
  }

  Future<void> _loadImagesFromSupabase() async {
    try {
      final storage = _sb.storage;
      String prefix = widget.folderPath.trim();
      if (prefix.isNotEmpty && !prefix.endsWith('/')) prefix = '$prefix/';

      // List files in the bucket/folder
      final List<FileObject> files = await storage
          .from(widget.bucketName)
          .list(path: prefix);

      // Build public URLs (assumes the bucket is public)
      final urls = <String>[];
      for (final f in files) {
        final path = '$prefix${f.name}';
        final url = storage.from(widget.bucketName).getPublicUrl(path);
        if (url.isNotEmpty) urls.add(url);
        if (urls.length >= widget.maxCards) break;
      }

      // Ensure exactly maxCards items (duplicate or fallback if needed)
      List<String> finalUrls;
      if (urls.isEmpty) {
        // Fallback placeholders (replace these with your edited pictures if desired)
        finalUrls = List.generate(
          widget.maxCards,
          (i) => 'https://via.placeholder.com/1200x500.png?text=Ad+${i + 1}',
        );
      } else if (urls.length < widget.maxCards) {
        finalUrls = <String>[];
        while (finalUrls.length < widget.maxCards) {
          finalUrls.addAll(urls);
        }
        finalUrls = finalUrls.take(widget.maxCards).toList();
      } else {
        finalUrls = urls.take(widget.maxCards).toList();
      }

      if (!mounted) return;
      setState(() => _imageUrls = finalUrls);
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetLoopBase());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _imageUrls = List.generate(
          widget.maxCards,
          (i) => 'https://via.placeholder.com/1200x500.png?text=Ad+${i + 1}',
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _resetLoopBase());
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoScrollInterval, (_) {
      if (!mounted || _ctrl == null || !_ctrl!.hasClients || _len == 0) return;
      final next = (_ctrl!.page?.round() ?? 0) + 1;
      _ctrl!.animateToPage(
        next,
        duration: widget.scrollDuration,
        curve: Curves.easeInOutCubic, // smoother
      );
    });
  }

  void _resetLoopBase() {
    if (_ctrl == null || !_ctrl!.hasClients || _len == 0) return;
    final base = _len * 1000; // big base for infinite feel
    _ctrl!.jumpToPage(base);
    setState(() => _activeIndex = base % _len);
  }

  void _onScroll() {
    if (_ctrl == null || !_ctrl!.hasClients || _len == 0) return;
    final page = _ctrl!.page ?? 0.0;
    final idx = page.round() % _len;
    if (idx != _activeIndex && mounted) {
      setState(() => _activeIndex = idx);
    }
  }

  void _ensureController(double viewportWidth) {
    // Target width for each card
    final double displayWidth = math.min(widget.cardWidth, viewportWidth);
    // We want each "page" to be cardWidth + gap wide in the viewport
    double vf = (displayWidth + widget.gap) / viewportWidth;
    if (vf > 1.0)
      vf = 1.0; // if cardWidth exceeds viewport, fall back to full page

    if (_ctrl == null || _lastViewportWidth != viewportWidth) {
      final oldPage = (_ctrl?.hasClients ?? false)
          ? _ctrl!.page?.round() ?? 0
          : 0;
      _ctrl?.removeListener(_onScroll);
      _ctrl?.dispose();
      _ctrl = PageController(viewportFraction: vf);
      _ctrl!.addListener(_onScroll);
      _lastViewportWidth = viewportWidth;

      // Preserve current progress roughly when recreating controller
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _ctrl == null || !_ctrl!.hasClients || _len == 0)
          return;
        final base = _len * 1000 + (oldPage % _len);
        _ctrl!.jumpToPage(base);
        setState(() => _activeIndex = base % _len);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure there are exactly widget.maxCards items to render
    final items = _imageUrls.isEmpty
        ? List.generate(
            widget.maxCards,
            (i) => 'https://via.placeholder.com/1200x500.png?text=Ad+${i + 1}',
          )
        : _imageUrls.take(widget.maxCards).toList();
    final len = items.length;

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportWidth = constraints.maxWidth;
          _ensureController(viewportWidth);

          // Actual card width to render (cap when screen is smaller than 500)
          final double displayWidth = math.min(widget.cardWidth, viewportWidth);
          final double halfGap = widget.gap / 2;

          return Stack(
            children: [
              // Infinite-feel PageView
              PageView.builder(
                controller: _ctrl!,
                padEnds: false,
                itemBuilder: (context, index) {
                  final realIndex = index % len;
                  final imageUrl = items[realIndex];

                  return Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: displayWidth,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: halfGap),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentOrange.withOpacity(0.18),
                              blurRadius: 8,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Image from Supabase Storage (public URL)
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.accentOrange.withOpacity(
                                    0.9,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.white70,
                                    size: 36,
                                  ),
                                ),
                                loadingBuilder: (ctx, child, progress) {
                                  if (progress == null) return child;
                                  return Container(
                                    color: AppColors.accentOrange.withOpacity(
                                      0.85,
                                    ),
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2.5,
                                    ),
                                  );
                                },
                              ),
                              // Optional caption overlay (uses provided ads captions if any)
                              if (realIndex < widget.ads.length &&
                                  (widget.ads[realIndex].trim().isNotEmpty))
                                Container(
                                  alignment: Alignment.center,
                                  color: Colors.black26,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      widget.ads[realIndex],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Dots indicator (UPDATED: sync with scroll)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(len, (i) {
                      final isActive = _activeIndex == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: isActive ? 18 : 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.textWhite
                              : AppColors.textWhite.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
