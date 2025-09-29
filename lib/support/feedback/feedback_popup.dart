import 'package:flutter/material.dart';
import 'package:final_year_project/support/feedback/feedback_success_popup.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

/// Call this function anywhere to show feedback popup
/// Example: `showFeedbackPopup(context);`
void showFeedbackPopup(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final TextEditingController controller = TextEditingController();
  String? errorText;
  bool isLoading = false;

  showGeneralDialog(
    context: context,
    barrierLabel: "Feedback",
    barrierDismissible: true,
    barrierColor: AppColors.textBlack54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOutBack,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            void handleSubmit() {
              if (controller.text.trim().isEmpty) {
                setState(() {
                  errorText = "Feedback cannot be empty";
                });
                return;
              }

              // Start loading
              setState(() {
                isLoading = true;
                errorText = null;
              });

              // Wait 2 seconds, then close & show success
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.of(context).pop(); // Close feedback popup

                Future.microtask(() {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => const SuccessPopup(),
                  );
                });
              });
            }

            return AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: const [
                  Icon(Icons.feedback, color: AppColors.accentOrange),
                  SizedBox(width: 8),
                  Text(
                    "Feedback",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Share your thoughts with us",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    maxLength: 500,
                    onChanged: (value) {
                      setState(() {
                        errorText = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Write your feedback here",
                      hintStyle: const TextStyle(fontSize: 13),
                      counterText: "",
                      errorText: errorText,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.accentOrange,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${controller.text.length}/500",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textBlack,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isLoading ? null : handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.hintWhite,
                                  ),
                                )
                              : const Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
}
