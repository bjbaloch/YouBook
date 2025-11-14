import 'dart:async';
import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/profile/account/account.dart';
import 'package:final_year_project/profile/change_password/success_pass.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _oldPassError;
  String? _newPassError;
  String? _confirmPassError;

  bool _touchedNew = false;
  bool _touchedConfirm = false;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // 🔹 Password validation
  bool _validatePassword(String pass) {
    final regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    return regex.hasMatch(pass);
  }

  void _validateFields({bool fromButton = false}) {
    setState(() {
      final oldPass = _oldPasswordCtrl.text.trim();
      final newPass = _newPasswordCtrl.text.trim();
      final confirmPass = _confirmPasswordCtrl.text.trim();

      _oldPassError = (fromButton && oldPass.isEmpty)
          ? "Old password required"
          : null;

      if (_touchedNew || fromButton) {
        if (newPass.isEmpty) {
          _newPassError = "New password required";
        } else if (!_validatePassword(newPass)) {
          _newPassError =
              "Must have 8+ chars, upper, lower, number & special char";
        } else {
          _newPassError = null;
        }
      }

      if (_touchedConfirm || fromButton) {
        if (confirmPass.isEmpty) {
          _confirmPassError = "Confirm password required";
        } else if (confirmPass != newPass) {
          _confirmPassError = "Passwords do not match";
        } else {
          _confirmPassError = null;
        }
      }
    });
  }

  void _onContinue() {
    _validateFields(fromButton: true);

    if (_oldPassError != null ||
        _newPassError != null ||
        _confirmPassError != null) {
      return; // Stop if there are validation errors
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SuccessPopup(),
      );
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
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 45,
        title: Text(
          "Change Password",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cs.onPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: cs.onPrimary,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AccountPage()),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Info Text ----
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Please enter your new password and confirm it to update your account.",
              style: TextStyle(fontSize: 14, color: cs.onBackground),
              textAlign: TextAlign.left,
            ),
          ),

          // ---- Main Card Section ----
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
                children: [
                  Image.asset("assets/password/password_icon.png", height: 100),
                  const SizedBox(height: 20),

                  // Old Password
                  _buildPasswordField(
                    controller: _oldPasswordCtrl,
                    label: "Old Password",
                    obscure: _obscureOld,
                    onToggle: () => setState(() => _obscureOld = !_obscureOld),
                    errorText: _oldPassError,
                    onChanged: (_) => _validateFields(),
                  ),
                  const SizedBox(height: 12),

                  // New Password
                  _buildPasswordField(
                    controller: _newPasswordCtrl,
                    label: "New Password",
                    obscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                    errorText: _newPassError,
                    onTap: () => setState(() => _touchedNew = true),
                    onChanged: (_) => _validateFields(),
                  ),
                  const SizedBox(height: 12),

                  // Confirm Password
                  _buildPasswordField(
                    controller: _confirmPasswordCtrl,
                    label: "Confirm Password",
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    errorText: _confirmPassError,
                    onTap: () => setState(() => _touchedConfirm = true),
                    onChanged: (_) => _validateFields(),
                  ),
                  const SizedBox(height: 24),

                  // ---- Update Button ----
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _onContinue,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.hintWhite,
                              ),
                            )
                          : const Text(
                              "Update",
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- TextField Builder ----
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? errorText,
    void Function(String)? onChanged,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isError = errorText != null && errorText.isNotEmpty;

    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      onTap: onTap,
      style: TextStyle(color: cs.onSurface),
      cursorColor: AppColors.accentOrange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isError ? Colors.red : cs.onSurface.withOpacity(0.7),
        ),
        filled: true,
        fillColor: cs.background,
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.redAccent : cs.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.redAccent : AppColors.accentOrange,
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: cs.onSurface,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
