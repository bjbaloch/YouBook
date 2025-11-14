/// Main entry point for YouBook Flutter application
import 'package:flutter/material.dart';
import 'package:final_year_project/core/config/supabase_config.dart';
import 'package:final_year_project/core/theme/app_colors.dart';
import 'package:final_year_project/features/welcome/ui/welcome_page.dart';
import 'package:final_year_project/features/login/ui/login_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseConfig.initialize();

  // Load saved theme before building the app
  await AppTheme.init();

  runApp(const YouBook());
}

class YouBook extends StatelessWidget {
  const YouBook({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.mode,
      builder: (context, mode, _) {
        final lightTheme = AppTheme.light.copyWith(
          textTheme: AppTheme.light.textTheme.apply(fontFamily: 'Roboto'),
          primaryTextTheme: AppTheme.light.primaryTextTheme.apply(
            fontFamily: 'Roboto',
          ),
        );

        final darkTheme = AppTheme.dark.copyWith(
          textTheme: AppTheme.dark.textTheme.apply(fontFamily: 'Roboto'),
          primaryTextTheme: AppTheme.dark.primaryTextTheme.apply(
            fontFamily: 'Roboto',
          ),
        );

        final themeData = mode == ThemeMode.dark ? darkTheme : lightTheme;

        return MaterialApp(
          title: 'YOUBOOK',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          home: AnimatedTheme(
            data: themeData,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: const WelcomePage(),
          ),
          routes: {
            '/login': (context) => const LoginPage(),
          },
        );
      },
    );
  }
}
