// app_colors.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color background = Color.fromARGB(255, 240, 234, 219);
  static const Color lightSeaGreen = Color.fromARGB(255, 20, 128, 123);
  static const Color accentOrange = Color(0xFFFFA800);
  static const Color logoYellow = Color(0xFFFFFF00);
  static const Color lightOrange = Color.fromARGB(255, 247, 182, 50);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF000000);
  static const Color textBlack54 = Color(0x8A000000);

  static const Color hintWhite = Color.fromARGB(179, 255, 255, 255);
  static const Color errorRed = Color(0xFFFF0000);

  static const Color dialogBg = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0x99000000);

  static const Color successGreen = Color(0xFF2E7D32);
  static const Color hintGrey = Color(0x99000000);

  static const Color primaryGreenDark = Color(0xFF0E8A18);
  static const Color dangerRed = Color(0xFFF50000);

  static const Color overlay = Color(0x55000000);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color grey = Color.fromRGBO(158, 158, 158, 1);

  static const Color accent = Color(0xFFFFA800);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);

  static const Color inputBorder = Color(0xFF000000);
  static const Color hint = Color(0x99000000);

  static const Color circleGreen = Color(0xFF12A21C);
  static const Color textOnCircle = Color(0xFFFFFFFF);
}

/// App-wide theme controller + ThemeData using your color schema.
class AppTheme {
  static const _kPrefKeyDark = 'app_theme_dark';

  /// Notifier for current theme mode
  static final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  /// Call this before runApp to restore saved theme
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_kPrefKeyDark) ?? false;
      mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      mode.value = ThemeMode.light;
    }
  }

  /// Toggle helper: true = dark, false = light (also persists)
  static Future<void> setDark(bool isDark) async {
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefKeyDark, isDark);
    } catch (_) {
      // ignore persistence errors
    }
  }

  /// Light theme
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.lightSeaGreen,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.lightSeaGreen,
      onPrimary: AppColors.textWhite,
      secondary: AppColors.accentOrange,
      onSecondary: AppColors.textWhite,
      error: AppColors.errorRed,
      onError: AppColors.textWhite,
      background: AppColors.background,
      onBackground: AppColors.textBlack,
      surface: AppColors.dialogBg,
      onSurface: AppColors.textBlack,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSeaGreen,
      foregroundColor: AppColors.textWhite,
      iconTheme: IconThemeData(color: AppColors.textWhite),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSeaGreen,
      selectedItemColor: AppColors.textWhite,
      unselectedItemColor: AppColors.textWhite.withOpacity(0.9),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.logoYellow),
      trackColor: MaterialStateProperty.resolveWith(
        (states) => AppColors.logoYellow.withOpacity(
          states.contains(MaterialState.selected) ? 0.55 : 0.25,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.lightSeaGreen,
      contentTextStyle: TextStyle(color: AppColors.textWhite),
    ),
    useMaterial3: false,
  );

  /// Dark theme
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF101214),
    primaryColor: AppColors.lightSeaGreen,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.lightSeaGreen,
      onPrimary: AppColors.textWhite,
      secondary: AppColors.accentOrange,
      onSecondary: AppColors.textWhite,
      error: AppColors.errorRed,
      onError: AppColors.textWhite,
      background: Color(0xFF101214),
      onBackground: AppColors.textWhite,
      surface: Color(0xFF1A1D1F),
      onSurface: AppColors.textWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSeaGreen,
      foregroundColor: AppColors.textWhite,
      iconTheme: IconThemeData(color: AppColors.textWhite),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSeaGreen,
      selectedItemColor: AppColors.textWhite,
      unselectedItemColor: AppColors.textWhite.withOpacity(0.9),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.logoYellow),
      trackColor: MaterialStateProperty.resolveWith(
        (states) => AppColors.logoYellow.withOpacity(
          states.contains(MaterialState.selected) ? 0.55 : 0.25,
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.lightSeaGreen,
      contentTextStyle: TextStyle(color: AppColors.textWhite),
    ),
    useMaterial3: false,
  );

  /// Widget to wrap MaterialApp for smooth transitions
  static Widget themedApp(Widget Function(BuildContext, ThemeMode) builder) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: mode,
      builder: (context, themeMode, _) {
        return AnimatedTheme(
          data: themeMode == ThemeMode.dark ? dark : light,
          duration: const Duration(milliseconds: 400), // smooth transition
          curve: Curves.easeInOut,
          child: builder(context, themeMode),
        );
      },
    );
  }
}
