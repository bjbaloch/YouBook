// lib/Success/success_otp_popup.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:final_year_project/profile/account/account.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class SuccessOtpPopup extends StatefulWidget {
  const SuccessOtpPopup({super.key});

  @override
  State<SuccessOtpPopup> createState() => _SuccessOtpPopupState();
}

class _SuccessOtpPopupState extends State<SuccessOtpPopup>
    with SingleTickerProviderStateMixin {
  bool _canClose = false;
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for fade transition
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Ensure popup visible for at least 3 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _canClose = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToAccount() async {
    if (!_canClose || !mounted) return;

    await _controller.reverse();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccountPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 400 ? 350 : screenWidth - 60;
    const double dialogHeight = 260;

    return WillPopScope(
      onWillPop: () async => false, // prevent premature close
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _goToAccount,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Green Circle with Check Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.circleGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 55,
                          color: AppColors.textOnCircle,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Success Text
                      Text(
                        "OTP has been verified\nSuccessfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
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

/// Helper to open the OTP success popup with fade transition
Future<void> showSuccessOtpPopup(BuildContext context) async {
  Navigator.of(
    context,
    rootNavigator: true,
  ).popUntil((route) => route is PageRoute);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    //barrierLabel: "SuccessOtpPopup",
    barrierColor: AppColors.overlay,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const SuccessOtpPopup(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}
