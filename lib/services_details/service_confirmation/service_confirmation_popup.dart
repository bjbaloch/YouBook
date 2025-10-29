import 'package:final_year_project/add_service/add_service_page.dart';
import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

// ==============================
// Success Dialog
// ==============================
void showServiceSuccessDialog(BuildContext parentContext) {
  final cs = Theme.of(parentContext).colorScheme;

  // ✅ Ensure dialog shows after any previous pop
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!parentContext.mounted) return; // safeguard

    showGeneralDialog(
      context: parentContext,
      barrierDismissible: false,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.successGreen,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Service has been added successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),

                // ✅ OK button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      Navigator.pushReplacement(
                        parentContext,
                        MaterialPageRoute(
                          builder: (context) => const ServicesPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  });
}
