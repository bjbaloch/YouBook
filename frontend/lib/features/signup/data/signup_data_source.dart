/// Signup Data Source - Handles all data operations for signup
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/core/config/supabase_config.dart';

class SignupDataSource {
  final SupabaseClient supabaseClient;

  SignupDataSource({
    SupabaseClient? supabaseClient,
  })  : supabaseClient = supabaseClient ?? SupabaseConfig.client;

  /// Check internet connection
  Future<bool> hasInternet() async {
    try {
      final res = await InternetAddress.lookup('example.com')
          .timeout(const Duration(seconds: 2));
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Check if email already exists
  Future<bool> checkEmailAvailability(String email) async {
    try {
      final result = await supabaseClient
          .from('profiles')
          .select('id')
          .ilike('email', email)
          .maybeSingle();
      return result == null;
    } catch (e) {
      if (e is SocketException) rethrow;
      return false;
    }
  }

  /// Check if phone already exists
  Future<bool> checkPhoneAvailability(String phone) async {
    try {
      final result = await supabaseClient
          .from('profiles')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
      return result == null;
    } catch (e) {
      if (e is SocketException) rethrow;
      return false;
    }
  }

  /// Check if CNIC already exists
  Future<bool> checkCnicAvailability(String cnic) async {
    try {
      final result = await supabaseClient
          .from('profiles')
          .select('id')
          .eq('cnic', cnic)
          .maybeSingle();
      return result == null;
    } catch (e) {
      if (e is SocketException) rethrow;
      return false;
    }
  }

  /// Check all fields availability at once
  Future<Map<String, bool>> checkFieldsAvailability({
    required String email,
    required String phone,
    required String cnic,
  }) async {
    try {
      final List<Future<dynamic>> futures = <Future<dynamic>>[
        supabaseClient
            .from('profiles')
            .select('id')
            .ilike('email', email)
            .maybeSingle(),
        supabaseClient
            .from('profiles')
            .select('id')
            .eq('phone', phone)
            .maybeSingle(),
        supabaseClient
            .from('profiles')
            .select('id')
            .eq('cnic', cnic)
            .maybeSingle(),
      ];

      final results = await Future.wait<dynamic>(futures);
      
      return {
        'email': results[0] == null,
        'phone': results[1] == null,
        'cnic': results[2] == null,
      };
    } catch (e) {
      if (e is SocketException) rethrow;
      return {'email': false, 'phone': false, 'cnic': false};
    }
  }

  /// Sign up user with Supabase
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String cnic,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password.trim(),
        data: {
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'cnic': cnic.trim(),
        },
        emailRedirectTo: 'youbook://auth-callback',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Create user profile
  Future<void> createProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
    required String cnic,
  }) async {
    try {
      await supabaseClient.from('profiles').upsert({
        'id': userId,
        'email': email.trim().toLowerCase(),
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'cnic': cnic.trim(),
        'role': null,
        'avatar_url': null,
        'address': null,
        'city': null,
        'state_province': null,
        'country': null,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Continue after email confirmation
  Future<AuthResponse> continueAfterConfirmation({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

