import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/manager_home/manager_home.dart';

// 🚨 Notifications Page Main Widget
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,

      // ==============================
      // APP BAR
      // ==============================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          toolbarHeight: 45,
          backgroundColor: cs.primary,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () {
              Navigator.of(context).pushReplacement(_createRoute());
            },
          ),
          centerTitle: true,
          title: Text(
            'Notifications',
            style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () {
                  _showClearConfirmationDialog(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.accentOrange,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ==============================
      // BODY - Empty notifications UI
      // ==============================
      body: _buildEmptyState(context),
    );
  }
}

// ==============================
// Smooth transition to ManagerHome
// ==============================
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const ManagerHome(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(-0.2, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      final fadeAnim = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      );
      return FadeTransition(
        opacity: fadeAnim,
        child: SlideTransition(position: animation.drive(tween), child: child),
      );
    },
  );
}

// ==============================
// WIDGET: Empty Notification State
// ==============================
Widget _buildEmptyState(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.notifications_active,
          size: 100,
          color: AppColors.accent.withOpacity(0.7),
        ),
        const SizedBox(height: 16),
        Text(
          "You don't have any notification",
          style: TextStyle(
            color: cs.onBackground.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

// ==============================
// POPUP: Confirmation Dialog
// ==============================
void _showClearConfirmationDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  // ✅ Capture parent context before dialog opens
  final parentContext = context;

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
                "Clear All Notifications",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                "Are you sure you want to clear all Notifications?",
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

                          // wait 3 sec
                          await Future.delayed(const Duration(seconds: 3));

                          // ✅ close confirm dialog
                          Navigator.of(
                            dialogContext,
                            rootNavigator: true,
                          ).pop();

                          // ✅ then show success dialog using parentContext
                          Future.delayed(const Duration(milliseconds: 150), () {
                            _showSuccessDialog(parentContext);
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

// ==============================
// POPUP: Success Dialog
// ==============================
void _showSuccessDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
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
              Icon(Icons.check_circle, size: 80, color: AppColors.successGreen),
              SizedBox(height: 16),
              Text(
                "Your all notifications has been deleted successfully",
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
}
