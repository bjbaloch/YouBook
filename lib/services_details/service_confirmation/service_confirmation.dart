import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/services_details/service_confirmation/service_confirmation_popup.dart';

// ==============================
// Confirmation Dialog
// ==============================
void showServiceConfirmationDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final parentContext = context; // ✅ safe outer context

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                "Service Details Confirmation",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                "Are you sure you provided the correct service information?",
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                // Cancel
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    side: const BorderSide(color: AppColors.accentOrange),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),

                // Confirm with loader
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() => isLoading = true);

                          // show 3s loader
                          await Future.delayed(const Duration(seconds: 3));

                          // ✅ close the confirmation dialog safely
                          Navigator.of(
                            parentContext,
                            rootNavigator: true,
                          ).pop();

                          // ✅ then open success dialog with the safe parent context
                          Future.delayed(const Duration(milliseconds: 120), () {
                            showServiceSuccessDialog(parentContext);
                          });
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          );
        },
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
}
