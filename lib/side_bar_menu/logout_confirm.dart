import 'package:flutter/material.dart';
import 'package:final_year_project/Login/login_page.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

Future<bool?> showLogoutDialog(BuildContext context) {
  // Automatically picks the right colors from current theme (light/dark)
  final cs = Theme.of(context).colorScheme;

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Logout Dialog",
    barrierColor: AppColors.textBlack54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim1, anim2) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: FadeTransition(
          opacity: anim1,
          child: AlertDialog(
            backgroundColor: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              '     Are you sure you want to\n                   log out',
              style: TextStyle(
                fontSize: 18,
                color: cs.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            actions: [
              Row(
                children: [
                  // Cancel: Close popup
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: cs.secondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: cs.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Yes: Close popup then navigate to login page
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                        Future.microtask(() {
                          Navigator.of(context).pushAndRemoveUntil(
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    final fade = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOut,
                                    );
                                    final slide =
                                        Tween<Offset>(
                                          begin: const Offset(0.2, 0),
                                          end: Offset.zero,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animation,
                                            curve: Curves.easeOutCubic,
                                          ),
                                        );

                                    return FadeTransition(
                                      opacity: fade,
                                      child: SlideTransition(
                                        position: slide,
                                        child: child,
                                      ),
                                    );
                                  },
                            ),
                            (route) => false,
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                ],
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
