/// Profile Logic - Business logic for profile management
import 'package:flutter/material.dart';
import 'package:final_year_project/features/profile/data/profile_data_source.dart';

class ProfileLogic {
  final ProfileDataSource _dataSource;
  final BuildContext context;

  ProfileLogic({
    required BuildContext this.context,
    ProfileDataSource? dataSource,
  }) : _dataSource = dataSource ?? ProfileDataSource();

  /// Load user profile
  Future<ProfileData> loadProfile() async {
    try {
      final user = _dataSource.getCurrentUser();
      if (user == null) {
        return ProfileData.empty();
      }

      final row = await _dataSource.getProfile(user.id);
      
      String? fullName;
      String? avatarUrl;
      String? phone;
      String? cnic;
      String? address;
      String? city;
      String? stateProvince;
      String? country;
      String? email;

      if (row != null) {
        fullName = (row['full_name'] as String?)?.trim();
        avatarUrl = (row['avatar_url'] as String?)?.trim();
        phone = (row['phone'] as String?)?.trim();
        cnic = (row['cnic'] as String?)?.trim();
        address = (row['address'] as String?)?.trim();
        city = (row['city'] as String?)?.trim();
        stateProvince = (row['state_province'] as String?)?.trim();
        country = (row['country'] as String?)?.trim();
        email = (row['email'] as String?)?.trim();
      }

      fullName ??= (user.userMetadata?['full_name'] as String?) ??
          (user.userMetadata?['name'] as String?);
      
      return ProfileData(
        fullName: fullName ?? 'Name',
        email: email ?? user.email ?? 'Email',
        avatarUrl: (avatarUrl != null && avatarUrl.isNotEmpty) ? avatarUrl : null,
        phone: phone,
        cnic: cnic,
        address: address,
        city: city,
        stateProvince: stateProvince,
        country: country,
      );
    } catch (e) {
      return ProfileData.empty();
    }
  }

  /// Update profile
  Future<bool> updateProfile({
    required String userId,
    String? fullName,
    String? cnic,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
  }) async {
    try {
      await _dataSource.updateProfile(
        userId: userId,
        fullName: fullName,
        cnic: cnic,
        address: address,
        city: city,
        stateProvince: stateProvince,
        country: country,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload avatar
  Future<String?> uploadAvatar(String userId, String filePath) async {
    try {
      return await _dataSource.uploadAvatar(userId, filePath);
    } catch (e) {
      return null;
    }
  }

  /// Validate CNIC format
  bool validateCnic(String cnic) {
    final regex = RegExp(r'^\d{5}-\d{7}-\d$');
    return regex.hasMatch(cnic);
  }
}

/// Profile data model
class ProfileData {
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String? cnic;
  final String? address;
  final String? city;
  final String? stateProvince;
  final String? country;

  ProfileData({
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.phone,
    this.cnic,
    this.address,
    this.city,
    this.stateProvince,
    this.country,
  });

  factory ProfileData.empty() {
    return ProfileData(
      fullName: 'Name',
      email: 'Email',
    );
  }
}

