/// Login Data Source - Handles all data operations for login
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/core/config/supabase_config.dart';
import 'package:final_year_project/shared/api/api_client.dart';

class LoginDataSource {
  final SupabaseClient supabaseClient;

  LoginDataSource({
    SupabaseClient? supabaseClient,
  })  : supabaseClient = supabaseClient ?? SupabaseConfig.client;

  /// Login with email and password using Supabase
  Future<AuthResponse> loginWithSupabase({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Login with email and password using Python backend API
  Future<Map<String, dynamic>> loginWithApi({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post('/auth/login', {
        'email': email.trim(),
        'password': password.trim(),
      });
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile from Supabase
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update/upsert user profile in Supabase
  Future<void> upsertProfile({
    required String id,
    required String email,
    String? fullName,
    String? phone,
    String? cnic,
  }) async {
    try {
      await supabaseClient.from('profiles').upsert({
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'cnic': cnic,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore errors for now
    }
  }
}

