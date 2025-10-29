import 'dart:async';
import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/profile/success_popup/success_popup.dart';

class EmailOtpPage extends StatefulWidget {
  const EmailOtpPage({super.key});

  @override
  State<EmailOtpPage> createState() => _EmailOtpPageState();
}

class _EmailOtpPageState extends State<EmailOtpPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  int _secondsRemaining = 0;
  Timer? _timer;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (var ctrl in _otpControllers) {
      ctrl.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    if (_secondsRemaining <= 0) return "00 : 00";
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes : $seconds";
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyOtp() {
    final otp = _otpControllers.map((e) => e.text).join();
    debugPrint("Entered OTP (Email): $otp");

    setState(() => _isVerifying = true);

    // Fake verification delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() => _isVerifying = false);

      // 👉 Navigate directly to SuccessPopup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => SuccessOtpPopup(), // 👈 your popup
      );
    });
  }

  void _resendCode() {
    setState(() => _isResending = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isResending = false);
      _startCountdown();
      debugPrint("OTP code resent to email");
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        toolbarHeight: 45,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "OTP Authentication",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cs.onPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: cs.onPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "We have sent a 6 digits verification code to your email address.\n"
              "Please enter the OTP code to complete your progress to update your account.\n"
              "Make sure you don’t share your OTP to others.",
              style: TextStyle(fontSize: 14, color: cs.onBackground),
              textAlign: TextAlign.left,
            ),
          ),

          // Main Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Image
                  Image.asset("assets/otp/otp.png", height: 100),
                  const SizedBox(height: 20),

                  // Label
                  Text(
                    "Enter OTP Code",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // OTP Input fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (i) => SizedBox(
                        width: 42,
                        child: TextField(
                          controller: _otpControllers[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counter: const Offstage(),
                            filled: true,
                            fillColor: cs.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cs.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: cs.secondary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5) {
                              FocusScope.of(context).nextFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isVerifying ? null : _verifyOtp,
                      child: _isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.hintWhite,
                              ),
                            )
                          : const Text(
                              "Verify now",
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Timer
                  if (_secondsRemaining > 0) ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _formattedTime,
                        key: ValueKey(_formattedTime),
                        style: TextStyle(fontSize: 16, color: cs.onPrimary),
                      ),
                    ),
                    Text(
                      "Time remaining",
                      style: TextStyle(color: cs.onPrimary),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Resend
                  Column(
                    children: [
                      Text(
                        "Don’t receive OTP?",
                        style: TextStyle(color: cs.onPrimary),
                      ),
                      TextButton(
                        onPressed: (_isResending || _secondsRemaining > 0)
                            ? null
                            : _resendCode,
                        child: _isResending
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentOrange,
                                ),
                              )
                            : Text(
                                "Resend code",
                                style: TextStyle(
                                  color: (_secondsRemaining > 0)
                                      ? cs.onPrimary.withOpacity(0.5)
                                      : cs.secondary,
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
    );
  }
}
