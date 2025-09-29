// main.dart
import 'package:final_year_project/Login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'welcome/welcome_page.dart';
import 'package:final_year_project/color_schema/app_colors.dart'; // AppTheme for light/dark

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://blycroutezsjhduujaai.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJseWNyb3V0ZXpzamhkdXVqYWFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4NDA4NTMsImV4cCI6MjA3MTQxNjg1M30.qcUskhKy_UR-IqWaECfI3j7CbJ66xtLCSedg6CKVkfQ",
  );

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
            duration: const Duration(milliseconds: 400), // smooth transition
            curve: Curves.easeInOut,
            child: const WelcomePage(),
          ),
          routes: {'/login': (context) => const LoginPage()},
        );
      },
    );
  }
}
