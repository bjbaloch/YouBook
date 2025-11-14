/// Login Logic - Business logic for login feature
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/features/login/data/login_data_source.dart';

class LoginLogic {
  final LoginDataSource _dataSource;
  final BuildContext context;

  LoginLogic({
    required BuildContext this.context,
    LoginDataSource? dataSource,
  }) : _dataSource = dataSource ?? LoginDataSource();

  /// Check if error is a network error
  bool isNetworkError(dynamic error) {
    if (error is SocketException) return true;
    final msg = error.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('host lookup') ||
        msg.contains('failed host lookup') ||
        msg.contains('socket') ||
        msg.contains('timed out') ||
        msg.contains('xmlhttprequest') ||
        msg.contains('failed to fetch');
  }

  /// Handle login process
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Use Supabase for now (can switch to Python API later)
      final response = await _dataSource.loginWithSupabase(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // Ensure profile exists/updated
        final authUser = _dataSource.supabaseClient.auth.currentUser;
        if (authUser != null) {
          await _dataSource.upsertProfile(
            id: authUser.id,
            email: authUser.email ?? email,
            fullName: authUser.userMetadata?['full_name'] as String?,
            phone: authUser.userMetadata?['phone'] as String?,
            cnic: authUser.userMetadata?['cnic'] as String?,
          );
        }

        // Get user role for navigation
        String? role;
        try {
          final profile = await _dataSource.getProfile(authUser!.id);
          role = profile?['role'] as String?;
        } catch (_) {
          role = null;
        }

        return LoginResult.success(role: role?.toLowerCase().trim());
      }

      return LoginResult.failure('Login failed');
    } on SocketException {
      return LoginResult.failure('No internet connection. Please check your network.');
    } on AuthException catch (e) {
      if (isNetworkError(e)) {
        return LoginResult.failure('No internet connection. Please check your network.');
      }
      return LoginResult.failure('Invalid email or password');
    } catch (e) {
      if (isNetworkError(e)) {
        return LoginResult.failure('No internet connection. Please check your network.');
      }
      return LoginResult.failure('Invalid email or password');
    }
  }

  /// Validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }
}

/// Login result model
class LoginResult {
  final bool success;
  final String? message;
  final String? role;

  LoginResult.success({this.role})
      : success = true,
        message = null;

  LoginResult.failure(this.message)
      : success = false,
        role = null;
}

