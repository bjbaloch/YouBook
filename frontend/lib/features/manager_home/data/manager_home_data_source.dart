/// Manager Home Data Source - Handles data operations for manager home
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/core/config/supabase_config.dart';

class ManagerHomeDataSource {
  final SupabaseClient supabaseClient;

  ManagerHomeDataSource({
    SupabaseClient? supabaseClient,
  })  : supabaseClient = supabaseClient ?? SupabaseConfig.client;

  /// Get user profile data
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

  /// Get current user
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }
}

