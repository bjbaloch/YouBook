/// Signup Logic - Business logic for signup feature
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:final_year_project/features/signup/data/signup_data_source.dart';
import 'package:final_year_project/shared/utils/signup_errors.dart' as errs;

class SignupLogic {
  final SignupDataSource _dataSource;
  final BuildContext context;

  SignupLogic({
    required BuildContext this.context,
    SignupDataSource? dataSource,
  }) : _dataSource = dataSource ?? SignupDataSource();

  // Validation regexes
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
  );
  static final RegExp phoneRegex = RegExp(r'^(03|92)\d{9}$');

  String canonicalEmail(String s) => s.trim().toLowerCase();

  /// Check if error is network error
  bool isNetworkError(dynamic error) {
    return errs.SignUpErrorUtils.looksLikeNetworkIssue(error);
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Enter email";
    if (!emailRegex.hasMatch(value)) return "Enter valid email";
    return null;
  }

  /// Validate phone
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Enter phone number";
    if (!phoneRegex.hasMatch(value)) return "Enter valid phone number";
    return null;
  }

  /// Validate CNIC
  String? validateCnic(String? value) {
    if (value == null || value.isEmpty) return "Enter CNIC";
    if (value.length != 15) return "Invalid CNIC format";
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Enter password";
    if (!passwordRegex.hasMatch(value)) {
      return "Must have 8+ chars, upper, lower, number, special";
    }
    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value, String password) {
    if (value != password) return "Passwords do not match";
    return null;
  }

  /// Format CNIC
  String formatCnic(String value) {
    String numbers = value.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    if (numbers.length > 5) {
      formatted = numbers.substring(0, 5) + '-';
      if (numbers.length > 12) {
        formatted += numbers.substring(5, 12) + '-' + numbers.substring(12);
      } else if (numbers.length > 5) {
        formatted += numbers.substring(5);
      }
    } else {
      formatted = numbers;
    }
    return formatted;
  }

  /// Check email availability
  Future<String?> checkEmailAvailability(String email, {bool showError = true}) async {
    if (!emailRegex.hasMatch(email)) return null;

    try {
      final isAvailable = await _dataSource.checkEmailAvailability(
        canonicalEmail(email),
      );
      if (!isAvailable) {
        return errs.SignUpErrorUtils.emailDuplicateMsg;
      }
      return null;
    } on SocketException {
      if (showError) {
        return errs.SignUpErrorUtils.noInternetMsg;
      }
      return null;
    } catch (e) {
      if (showError && isNetworkError(e)) {
        return errs.SignUpErrorUtils.noInternetMsg;
      }
      return null;
    }
  }

  /// Check phone availability
  Future<String?> checkPhoneAvailability(String phone, {bool showError = true}) async {
    if (!phoneRegex.hasMatch(phone)) return null;

    try {
      final isAvailable = await _dataSource.checkPhoneAvailability(phone);
      if (!isAvailable) {
        return errs.SignUpErrorUtils.phoneDuplicateMsg;
      }
      return null;
    } on SocketException {
      if (showError) {
        return errs.SignUpErrorUtils.noInternetMsg;
      }
      return null;
    } catch (e) {
      if (showError && isNetworkError(e)) {
        return errs.SignUpErrorUtils.noInternetMsg;
      }
      return null;
    }
  }

  /// Check CNIC availability
  Future<String?> checkCnicAvailability(String cnic, {bool showError = true}) async {
    if (cnic.length != 15) return null;

    try {
      final isAvailable = await _dataSource.checkCnicAvailability(cnic);
      if (!isAvailable) {
        return errs.SignUpErrorUtils.cnicDuplicateMsg;
      }
      return null;
    } on SocketException {
      if (showError) {
        return errs.SignUpErrorUtils.noInternetMsg;
      }
      return null;
    } catch (e) {
      if (showError && isNetworkError(e)) {
        return errs.SignUpErrorUtils.noInternetMsg;
      }
      return null;
    }
  }

  /// Check all fields availability
  Future<Map<String, String?>> checkAllFieldsAvailability({
    required String email,
    required String phone,
    required String cnic,
  }) async {
    final results = await _dataSource.checkFieldsAvailability(
      email: canonicalEmail(email),
      phone: phone.trim(),
      cnic: cnic.trim(),
    );

    return {
      'email': results['email'] == false
          ? errs.SignUpErrorUtils.emailDuplicateMsg
          : null,
      'phone': results['phone'] == false
          ? errs.SignUpErrorUtils.phoneDuplicateMsg
          : null,
      'cnic': results['cnic'] == false
          ? errs.SignUpErrorUtils.cnicDuplicateMsg
          : null,
    };
  }

  /// Sign up process
  Future<SignupResult> signUp({
    required String name,
    required String email,
    required String phone,
    required String cnic,
    required String password,
  }) async {
    // Check internet
    if (!await _dataSource.hasInternet()) {
      return SignupResult.failure(errs.SignUpErrorUtils.noInternetMsg);
    }

    // Check field availability
    final fieldErrors = await checkAllFieldsAvailability(
      email: email,
      phone: phone,
      cnic: cnic,
    );

    if (fieldErrors.values.any((e) => e != null)) {
      return SignupResult.failure(
        fieldErrors.values.firstWhere((e) => e != null) ?? 'Field already exists',
      );
    }

    try {
      final canonicalEmailValue = canonicalEmail(email);
      final authResp = await _dataSource.signUp(
        email: canonicalEmailValue,
        password: password,
        fullName: name,
        phone: phone,
        cnic: cnic,
      );

      final userId = authResp.user?.id;
      if (userId != null) {
        await _dataSource.createProfile(
          userId: userId,
          email: canonicalEmailValue,
          fullName: name,
          phone: phone,
          cnic: cnic,
        );
      }

      if (authResp.session == null) {
        return SignupResult.emailConfirmationRequired();
      }

      return SignupResult.success();
    } catch (e) {
      final errorMsg = errs.SignUpErrorUtils.friendlyError(e);
      return SignupResult.failure(errorMsg);
    }
  }

  /// Continue after email confirmation
  Future<SignupResult> continueAfterConfirmation({
    required String email,
    required String password,
  }) async {
    if (!await _dataSource.hasInternet()) {
      return SignupResult.failure(errs.SignUpErrorUtils.noInternetMsg);
    }

    try {
      final response = await _dataSource.continueAfterConfirmation(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return SignupResult.success();
      }

      return SignupResult.failure("Could not continue. Please try again.");
    } catch (e) {
      return SignupResult.failure("Something went wrong. Please try again.");
    }
  }
}

/// Signup result model
class SignupResult {
  final bool success;
  final String? message;
  final bool emailConfirmationRequired;

  SignupResult.success()
      : success = true,
        message = null,
        emailConfirmationRequired = false;

  SignupResult.emailConfirmationRequired()
      : success = true,
        message = "We've sent a confirmation link to your email.",
        emailConfirmationRequired = true;

  SignupResult.failure(this.message)
      : success = false,
        emailConfirmationRequired = false;
}

