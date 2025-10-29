import 'package:final_year_project/profile/change_phone_number/phone_otp.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class ChangePhoneDialog {
  static void show(BuildContext context) {
    final TextEditingController phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        bool isLoading = false;
        String? phoneError;

        return StatefulBuilder(
          builder: (context, setState) {
            // Live validation on typing
            void _validatePhone(String value) {
              String input = value.trim();

              if (input.isEmpty) {
                setState(() => phoneError = "Phone number is required");
              } else if (!input.startsWith("03")) {
                setState(() => phoneError = "Must start with 03");
              } else if (input.length < 11) {
                setState(() => phoneError = "Must be at least 11 digits");
              } else if (input.length > 11) {
                setState(() => phoneError = "Must not exceed 11 digits");
              } else {
                setState(() => phoneError = null);
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
                    // Title Row
                    Row(
                      children: [
                        const Icon(Icons.phone, color: AppColors.accentOrange),
                        const SizedBox(width: 8),
                        Text(
                          "Change Phone number",
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
                        "Enter new phone number",
                        style: TextStyle(fontSize: 14, color: cs.onSurface),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Input field with validation
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      onChanged: _validatePhone,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textBlack,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: "Phone number",
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textBlack,
                        ),
                        errorText: phoneError,
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
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

                    // Buttons: Cancel + Verify
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: AppColors.textWhite,
                            minimumSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: (isLoading || phoneError != null)
                              ? null
                              : () {
                                  String newPhone = phoneCtrl.text.trim();
                                  _validatePhone(newPhone);

                                  if (phoneError != null) return;

                                  setState(() => isLoading = true);

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      Navigator.pop(ctx);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PhoneOtpPage(),
                                        ),
                                      );
                                    },
                                  );
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
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
