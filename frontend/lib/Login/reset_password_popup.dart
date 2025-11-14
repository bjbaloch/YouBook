import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'password_success_popup.dart';

class ResetPasswordPopup extends StatefulWidget {
  const ResetPasswordPopup({super.key});

  @override
  State<ResetPasswordPopup> createState() => _ResetPasswordPopupState();
}

class _ResetPasswordPopupState extends State<ResetPasswordPopup> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  // validation flags
  bool hasLower = false;
  bool hasUpper = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  String? _formError; // surface-level error (e.g., session expired)

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      hasLower = RegExp(r'[a-z]').hasMatch(value);
      hasUpper = RegExp(r'[A-Z]').hasMatch(value);
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(value);
      hasMinLength = value.length >= 8;
    });
  }

  bool _isNetworkError(dynamic e) {
    if (e is SocketException) return true;
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('host lookup') ||
        msg.contains('failed host lookup') ||
        msg.contains('socket') ||
        msg.contains('timed out') ||
        msg.contains('xmlhttprequest') ||
        msg.contains('failed to fetch');
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _formError = null;
    });

    try {
      // Latest supabase_flutter: updateUser with UserAttributes
      final resp = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );

      if (resp.user != null) {
        if (!mounted) return;

        // Close this ResetPasswordPopup BEFORE opening SuccessPopup
        Navigator.of(context).pop();
        // Give the Navigator a tick to remove this dialog before showing the next
        await Future.delayed(const Duration(milliseconds: 100));

        // Smooth navigation to success popup
        await _showSmoothDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: AppColors.overlay,
          child: const SuccessPopup(),
        );
      } else {
        setState(() => _formError = "Password reset failed. Please try again.");
      }
    } on AuthException catch (e) {
      if (_isNetworkError(e)) {
        setState(
          () =>
              _formError = "No internet connection. Please check your network.",
        );
      } else {
        // Common: session expired if user waited too long after OTP verify
        final msg = e.message.toLowerCase();
        if (msg.contains('session') ||
            msg.contains('expired') ||
            msg.contains('token')) {
          setState(
            () => _formError =
                "Your session expired. Request a new code and try again.",
          );
        } else {
          setState(() => _formError = e.message);
        }
      }
    } on SocketException {
      setState(
        () => _formError = "No internet connection. Please check your network.",
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        setState(
          () =>
              _formError = "No internet connection. Please check your network.",
        );
      } else {
        setState(() => _formError = "Something went wrong. Please try again.");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _rule(String text, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: ok ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: ok ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      // Block system back; do not navigate back to Forget Password
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: cs.surface,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Fixed max size; scroll inside; pad for keyboard
            final maxWidth = constraints.maxWidth.clamp(0.0, 520.0);
            final maxHeight = (MediaQuery.of(context).size.height * 0.75).clamp(
              320.0,
              560.0,
            );

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom:
                      20 +
                      MediaQuery.of(context).viewInsets.bottom, // keyboard-safe
                ),
                child: Form(
                  key: _formKey,
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(
                      overscroll: false,
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Reset password",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Please create a new strong password",
                            style: TextStyle(fontSize: 13, color: cs.onSurface),
                          ),
                          const SizedBox(height: 12),

                          // New password
                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            onChanged: _validatePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: "New password",
                              hintStyle: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureNew
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.onSurface),
                              ),
                            ),
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return "Enter new password";
                              if (!hasLower ||
                                  !hasUpper ||
                                  !hasNumber ||
                                  !hasSpecial ||
                                  !hasMinLength) {
                                return "Password must meet all requirements below";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          // Confirm password
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: "Confirm new password",
                              hintStyle: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: cs.onSurface),
                              ),
                            ),
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return "Confirm your password";
                              if (value != _newPasswordController.text.trim()) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Rules
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _rule(
                                  "At least one lowercase letter",
                                  hasLower,
                                ),
                                _rule(
                                  "At least one uppercase letter",
                                  hasUpper,
                                ),
                                _rule("At least one number", hasNumber),
                                _rule(
                                  "At least one special character",
                                  hasSpecial,
                                ),
                                _rule("Minimum 8 characters", hasMinLength),
                              ],
                            ),
                          ),

                          if (_formError != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _formError!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Change button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: _loading ? null : _resetPassword,
                              child: _loading
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: cs.onSecondary,
                                      ),
                                    )
                                  : Text(
                                      "Change",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: cs.onSecondary,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Smooth dialog helper (fade + gentle scale)
Future<T?> _showSmoothDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = false,
  Color barrierColor = AppColors.overlay,
  Duration duration = const Duration(milliseconds: 260),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor,
    transitionDuration: duration,
    pageBuilder: (context, anim1, anim2) =>
        SafeArea(child: Center(child: child)),
    transitionBuilder: (context, anim, secondary, widget) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
          child: widget,
        ),
      );
    },
  );
}

// Helper to open ResetPasswordPopup (non-dismissible and keyboard/overlay safe) with smooth transition
Future<void> showResetPasswordPopup(BuildContext context) {
  return _showSmoothDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.overlay,
    child: const ResetPasswordPopup(),
  );
}
