import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/manager_home/manager_home.dart';
import 'package:final_year_project/notification/clear_confirmation.dart';

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
            style: TextStyle(color: cs.onPrimary, fontSize: 20),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: InkWell(
                onTap: () => showClearConfirmationDialog(context),
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
        Image.asset(
          "assets/notification/notification_icon.png",
          height: 120,
          opacity: const AlwaysStoppedAnimation(0.6),
        ),
        const SizedBox(height: 16),
        Text(
          "You don't have any notification at the moment",
          style: TextStyle(
            color: cs.onBackground.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
