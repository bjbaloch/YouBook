import 'package:flutter/material.dart';
import 'package:final_year_project/Login/login_page.dart';

Future<bool?> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // 1) Do NOT close when screen is touched
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // 2) Cancel: close the popup
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Cancel', style: TextStyle(color: cs.onSurface)),
                ),
              ),
              const SizedBox(width: 12),
              // 3) Yes: close popup then navigate to login page
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                    // Navigate after the dialog closes
                    Future.microtask(() {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
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
      );
    },
  );
}
