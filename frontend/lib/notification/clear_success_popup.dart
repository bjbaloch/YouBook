import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

// ==============================
// Success Dialog
// ==============================
void showSuccessDialog(BuildContext parentContext) {
  final cs = Theme.of(parentContext).colorScheme;

  // ✅ Ensure dialog shows after any previous pop
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!parentContext.mounted) return; // safeguard

    showGeneralDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierLabel: "Dismiss", // ✅ REQUIRED when barrierDismissible is true
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
              children: const [
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.successGreen,
                ),
                SizedBox(height: 16),
                Text(
                  "Your all notifications have been deleted successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
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
