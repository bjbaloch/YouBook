import 'package:final_year_project/profile/change_email/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class ChangeEmailDialog {
  static void show(BuildContext context) {
    final TextEditingController emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        bool isLoading = false;
        String? emailError;

        return StatefulBuilder(
          builder: (context, setState) {
            // ✅ Email validation on typing
            void _validateEmail(String value) {
              String input = value.trim();
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

              if (input.isEmpty) {
                setState(() => emailError = "Email is required");
              } else if (!emailRegex.hasMatch(input)) {
                setState(() => emailError = "Invalid email format");
              } else {
                setState(() => emailError = null);
              }
            }

            return Dialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔶 Title
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Change email address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Subtitle
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Enter new email address",
                        style: TextStyle(fontSize: 14, color: cs.onSurface),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 🔶 Input field with live validation
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _validateEmail,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textBlack,
                      ),
                      decoration: InputDecoration(
                        labelText: "Email",
                        errorText: emailError,
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textBlack,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.accentOrange,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // 🔶 Buttons: Cancel + Verify
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 40),
                            side: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textBlack,
                            ),
                          ),
                        ),

                        // ✅ Verify button behaves like phone number one
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: AppColors.textWhite,
                            minimumSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: (isLoading || emailError != null)
                              ? null
                              : () {
                                  String newEmail = emailCtrl.text.trim();
                                  _validateEmail(newEmail);

                                  if (emailError != null) return;

                                  setState(() => isLoading = true);

                                  // Show 2s loader before navigating
                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (!context.mounted) return;
                                      Navigator.pop(ctx);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const EmailOtpPage(),
                                        ),
                                      );
                                    },
                                  );
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.hintWhite,
                                  ),
                                )
                              : const Text("Verify"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
