import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class SuccessPopup extends StatelessWidget {
  const SuccessPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, size: 80, color: AppColors.successGreen),
          SizedBox(height: 16),
          Text(
            "Your feedback has been submitted successfully.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text("Thank you for your feedback.", textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // close dialog
          child: const Text("OK"),
        ),
      ],
    );
  }
}
