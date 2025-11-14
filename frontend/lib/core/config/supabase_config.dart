/// Supabase Configuration - Centralized Supabase initialization
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase credentials
  static const String supabaseUrl = "https://blycroutezsjhduujaai.supabase.co";
  static const String supabaseAnonKey = 
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJseWNyb3V0ZXpzamhkdXVqYWFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4NDA4NTMsImV4cCI6MjA3MTQxNjg1M30.qcUskhKy_UR-IqWaECfI3j7CbJ66xtLCSedg6CKVkfQ";

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}

