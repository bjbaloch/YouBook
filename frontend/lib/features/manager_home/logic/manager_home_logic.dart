/// Manager Home Logic - Business logic for manager home
import 'package:flutter/material.dart';
import 'package:final_year_project/features/manager_home/data/manager_home_data_source.dart';

class ManagerHomeLogic {
  final ManagerHomeDataSource _dataSource;
  final BuildContext context;

  ManagerHomeLogic({
    required BuildContext this.context,
    ManagerHomeDataSource? dataSource,
  }) : _dataSource = dataSource ?? ManagerHomeDataSource();

  /// Load user profile
  Future<ProfileData> loadProfile() async {
    try {
      final user = _dataSource.getCurrentUser();
      if (user == null) {
        return ProfileData(
          displayName: "Guest",
          email: "guest@example.com",
          avatarUrl: null,
        );
      }

      final profile = await _dataSource.getProfile(user.id);
      if (profile == null) {
        return ProfileData(
          displayName: user.userMetadata?['full_name'] as String? ?? "Guest",
          email: user.email ?? "guest@example.com",
          avatarUrl: null,
        );
      }

      return ProfileData(
        displayName: profile['full_name'] as String? ?? "Guest",
        email: profile['email'] as String? ?? user.email ?? "guest@example.com",
        avatarUrl: profile['avatar_url'] as String?,
      );
    } catch (e) {
      return ProfileData(
        displayName: "Guest",
        email: "guest@example.com",
        avatarUrl: null,
      );
    }
  }

  /// Handle double back press
  bool handleBackPress(DateTime? lastBackPress) {
    final now = DateTime.now();
    if (lastBackPress == null ||
        now.difference(lastBackPress) > const Duration(seconds: 2)) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
      return false;
    }
    return true;
  }
}

/// Profile data model
class ProfileData {
  final String displayName;
  final String email;
  final String? avatarUrl;

  ProfileData({
    required this.displayName,
    required this.email,
    this.avatarUrl,
  });
}

