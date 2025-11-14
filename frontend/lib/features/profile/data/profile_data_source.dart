/// Profile Data Source - Handles profile data operations
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/core/config/supabase_config.dart';

class ProfileDataSource {
  final SupabaseClient supabaseClient;

  ProfileDataSource({
    SupabaseClient? supabaseClient,
  })  : supabaseClient = supabaseClient ?? SupabaseConfig.client;

  /// Get user profile data
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .select(
            'full_name, avatar_url, phone, cnic, address, city, state_province, country, email',
          )
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? cnic,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
  }) async {
    try {
      await supabaseClient.from('profiles').update({
        if (fullName != null) 'full_name': fullName,
        if (cnic != null) 'cnic': cnic,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (stateProvince != null) 'state_province': stateProvince,
        if (country != null) 'country': country,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload avatar
  Future<String?> uploadAvatar(String userId, String filePath) async {
    try {
      // TODO: Implement avatar upload to Supabase storage
      // For now, return null
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => supabaseClient.auth.onAuthStateChange;
}

