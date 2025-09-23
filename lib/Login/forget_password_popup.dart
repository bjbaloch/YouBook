import 'dart:async'; // Timer
import 'dart:io'; // SocketException + lookup
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'reset_password_popup.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class ForgetPasswordPopup extends StatefulWidget {
  const ForgetPasswordPopup({
    super.key,
    this.initialEmail, // Pass the login email to prefill
  });

  final String? initialEmail;

  @override
  State<ForgetPasswordPopup> createState() => _ForgetPasswordPopupState();
}

class _ForgetPasswordPopupState extends State<ForgetPasswordPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  final supabase = Supabase.instance.client;

  String? _emailError;
  String? _codeError;
  String? _successMessage;

  bool _isSending = false; // "Get" button spinner
  bool _isVerifying = false; // "Continue" button spinner

  // 90s resend cooldown
  static const int _cooldownSeconds = 90;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  // Real email validation
  final RegExp _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  bool get _hasInitialEmail =>
      widget.initialEmail != null && widget.initialEmail!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Prefill from login if provided
    if (_hasInitialEmail) {
      _emailController.text = widget.initialEmail!.trim();
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // Cross-platform network check (fast)
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
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

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_cooldown > 0) {
          _cooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // Send 6-digit email OTP (requires Email OTP enabled in Supabase Auth)
  Future<void> _sendResetCode() async {
    setState(() {
      _emailError = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() => _emailError = "Enter the email address");
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = "Please enter a valid email address");
      return;
    }
    if (_cooldown > 0) {
      // Extra guard: button is already disabled during cooldown
      return;
    }

    // Must not work offline
    if (!await _hasInternet()) {
      setState(
        () =>
            _emailError = "No internet connection. Please check your network.",
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        // Do NOT set emailRedirectTo or Supabase may send Magic Link instead of OTP
      );

      setState(() {
        _successMessage = "A 6-digit code has been sent to your email address.";
      });

      // Start 90s cooldown
      _startCooldown();

      // Move focus away
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } on AuthException catch (e) {
      if (_looksLikeNetworkError(e)) {
        setState(
          () => _emailError =
              "No internet connection. Please check your network.",
        );
      } else {
        final msg = e.message.toLowerCase();
        if (msg.contains('not found') || msg.contains('no user')) {
          setState(() => _emailError = "No account found with this email.");
        } else {
          setState(() => _emailError = "Error sending code: ${e.message}");
        }
      }
    } on SocketException {
      setState(
        () =>
            _emailError = "No internet connection. Please check your network.",
      );
    } catch (e) {
      if (_looksLikeNetworkError(e)) {
        setState(
          () => _emailError =
              "No internet connection. Please check your network.",
        );
      } else {
        setState(() => _emailError = "Error sending code. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Verify the OTP and proceed to reset password
  Future<void> _continue() async {
    setState(() {
      _codeError = null;
    });

    final code = _codeController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    if (code.isEmpty) {
      setState(() => _codeError = "Please enter the code");
      return;
    }
    if (code.length != 6) {
      setState(() => _codeError = "Code must be 6 digits");
      return;
    }

    // Must not work offline
    if (!await _hasInternet()) {
      setState(
        () => _codeError = "No internet connection. Please check your network.",
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // LATEST supabase_flutter (2.10.0)
      await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: code,
      );

      if (!mounted) return;

      // CLOSE this ForgetPasswordPopup before opening the ResetPasswordPopup
      Navigator.of(context).pop();

      // Then open ResetPasswordPopup
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.3),
        builder: (_) => const ResetPasswordPopup(),
      );
    } on AuthException catch (e) {
      if (_looksLikeNetworkError(e)) {
        setState(
          () =>
              _codeError = "No internet connection. Please check your network.",
        );
      } else {
        setState(() => _codeError = e.message);
      }
    } on SocketException {
      setState(
        () => _codeError = "No internet connection. Please check your network.",
      );
    } catch (e) {
      if (_looksLikeNetworkError(e)) {
        setState(
          () =>
              _codeError = "No internet connection. Please check your network.",
        );
      } else {
        setState(
          () => _codeError = "Invalid or expired code. Please try again.",
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fixed-size popup that won’t grow with the keyboard; scrolls internally if needed
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 500 ? 500 : screenWidth - 45;
    const double dialogHeight = 370;

    // Lock typing if login didn't pass an email
    final bool lockEmailField = !_hasInitialEmail;

    // Disable Get button when: sending, cooldown active, email empty/invalid
    final String emailTrim = _emailController.text.trim();
    final bool disableGetButton =
        _isSending ||
        _cooldown > 0 ||
        emailTrim.isEmpty ||
        !_emailRegex.hasMatch(emailTrim);

    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async => false, // Disable system back (use Cancel)
      child: Center(
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: cs.surface,
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(overscroll: false),
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            "Forget password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Email
                        const Text("Email address"),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                readOnly:
                                    lockEmailField, // lock typing if no email from login
                                enableInteractiveSelection: !lockEmailField,
                                onTap: lockEmailField
                                    ? () => FocusScope.of(context).unfocus()
                                    : null,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(color: cs.onSurface),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  hintText: lockEmailField
                                      ? "Enter email on Login page"
                                      : "Email address",
                                  hintStyle: TextStyle(
                                    color: cs.onSurface.withOpacity(0.4),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: cs.onSurface),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ElevatedButton(
                              onPressed: disableGetButton
                                  ? null
                                  : _sendResetCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              child: _isSending
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: cs.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      _cooldown > 0
                                          ? "Resend in ${_cooldown}s"
                                          : "Get",
                                      style: TextStyle(color: cs.onPrimary),
                                    ),
                            ),
                          ],
                        ),
                        if (lockEmailField) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Email is required from the Login page. Tap Cancel to go back.",
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (_emailError != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _emailError!,
                            style: TextStyle(color: cs.error, fontSize: 12),
                          ),
                        ],
                        if (_successMessage != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _successMessage!,
                            style: const TextStyle(
                              color: AppColors.successGreen,
                              fontSize: 12,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Code
                        const Text(
                          "Enter the code that was sent to your email",
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: TextStyle(color: cs.onSurface),
                          decoration: InputDecoration(
                            hintText: "Enter the code",
                            hintStyle: TextStyle(
                              color: cs.onSurface.withOpacity(0.4),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.onSurface),
                            ),
                          ),
                        ),
                        if (_codeError != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            _codeError!,
                            style: TextStyle(color: cs.error, fontSize: 12),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context); // back to login
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: cs.secondary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isVerifying ? null : _continue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: _isVerifying
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: cs.onSecondary,
                                      ),
                                    )
                                  : Text(
                                      "Continue",
                                      style: TextStyle(color: cs.onSecondary),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
