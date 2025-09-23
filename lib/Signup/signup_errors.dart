// signup_errors.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpErrorUtils {
  // Common messages
  static const String noInternetMsg =
      "No internet connection. Please check your network.";
  static const String emailDuplicateMsg =
      "This email is already registered, try logging in.";
  static const String phoneDuplicateMsg =
      "This phone number is already registered.";
  static const String cnicDuplicateMsg = "This CNIC is already registered.";

  // Safely convert anything (including null) to lowercase string
  static String toLowerSafe(dynamic v) =>
      (v == null ? '' : v.toString()).toLowerCase();

  static bool looksLikeNetworkIssue(dynamic error) {
    if (error is SocketException) return true;
    final msg = toLowerSafe(error);
    return msg.contains('network') ||
        msg.contains('host lookup') ||
        msg.contains('failed host lookup') ||
        msg.contains('timed out') ||
        msg.contains('connection refused') ||
        msg.contains('socket');
  }

  // User-friendly error string for SnackBars/logs
  static String friendlyError(dynamic error) {
    if (error is SocketException) {
      return noInternetMsg;
    }

    if (error is AuthException) {
      // In your SDK version, `message` is non-nullable
      final msg = toLowerSafe(error.message);
      if (msg.contains('already') &&
          (msg.contains('registered') ||
              msg.contains('exists') ||
              msg.contains('in use') ||
              msg.contains('used'))) {
        return emailDuplicateMsg;
      }
      if (looksLikeNetworkIssue(error)) return noInternetMsg;

      final raw = error.message; // no ?.
      return raw.isNotEmpty ? raw : "Something went wrong while signing up.";
    }

    if (error is PostgrestException) {
      // `message` is non-nullable in newer SDKs; `details`/`code` may be null
      final msg = toLowerSafe(error.message);
      final details = toLowerSafe(error.details);
      final code = (error.code ?? '').toString();

      final isDuplicate =
          code == '23505' ||
          msg.contains('duplicate') ||
          msg.contains('unique') ||
          details.contains('already exists');

      if (isDuplicate) {
        if (msg.contains('profiles_email_key') || details.contains('(email)')) {
          return emailDuplicateMsg;
        }
        if (msg.contains('profiles_phone_key') || details.contains('(phone)')) {
          return phoneDuplicateMsg;
        }
        if (msg.contains('profiles_cnic_key') || details.contains('(cnic)')) {
          return cnicDuplicateMsg;
        }
        return "One or more fields are already registered.";
      }

      final raw = error.message; // no ?.
      return raw.isNotEmpty ? raw : "A database error occurred.";
    }

    if (looksLikeNetworkIssue(error)) return noInternetMsg;
    return error.toString();
  }

  // Extract field-level duplicate errors from exceptions
  // Returns a map like {'email': '...', 'phone': '...'}
  static Map<String, String> extractDuplicateFieldErrors(dynamic error) {
    final Map<String, String> fieldErrors = {};

    if (error is AuthException) {
      final msg = toLowerSafe(error.message); // no ?.
      final isDup =
          msg.contains('already') &&
          (msg.contains('registered') ||
              msg.contains('exists') ||
              msg.contains('in use') ||
              msg.contains('used'));
      if (isDup) {
        fieldErrors['email'] = emailDuplicateMsg;
      }
      return fieldErrors;
    }

    if (error is PostgrestException) {
      final msg = toLowerSafe(error.message); // no ?.
      final details = toLowerSafe(error.details);
      final code = (error.code ?? '').toString();

      final isDuplicate =
          code == '23505' ||
          msg.contains('duplicate') ||
          msg.contains('unique') ||
          details.contains('already exists');

      if (isDuplicate) {
        if (msg.contains('profiles_email_key') || details.contains('(email)')) {
          fieldErrors['email'] = emailDuplicateMsg;
        }
        if (msg.contains('profiles_phone_key') || details.contains('(phone)')) {
          fieldErrors['phone'] = phoneDuplicateMsg;
        }
        if (msg.contains('profiles_cnic_key') || details.contains('(cnic)')) {
          fieldErrors['cnic'] = cnicDuplicateMsg;
        }
      }
    }

    return fieldErrors;
  }
}
