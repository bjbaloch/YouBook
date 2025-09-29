import 'dart:async';
import 'package:final_year_project/profile/update_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/side_bar_menu/logout_confirm.dart';
import 'package:final_year_project/manager_home/manager_home.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _sb = Supabase.instance.client;

  // Profile data
  String? _fullName;
  String? _email;
  String? _cnic;
  String? _phone;
  String? _avatarUrl;

  // Optional fields
  String? _address;
  String? _city;
  String? _stateProvince;
  String? _country;

  bool _loading = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _authSub = _sb.auth.onAuthStateChange.listen((_) => _loadUser());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = _sb.auth.currentUser;
      setState(() {
        _loading = true;
      });

      if (user == null) {
        setState(() {
          _fullName = null;
          _avatarUrl = null;
          _cnic = null;
          _phone = null;
          _address = null;
          _city = null;
          _stateProvince = null;
          _country = null;
          _email = null;
          _loading = false;
        });
        return;
      }

      String? fullName;
      String? avatarUrl;
      String? phone;
      String? cnic;
      String? address;
      String? city;
      String? stateProvince;
      String? country;
      String? email;

      try {
        final row = await _sb
            .from('profiles')
            .select(
              'full_name, avatar_url, phone, cnic, address, city, state_province, country, email',
            )
            .eq('id', user.id)
            .maybeSingle();

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
      } catch (e) {
        debugPrint('profiles fetch error: $e');
      }

      fullName ??=
          (user.userMetadata?['full_name'] as String?) ??
          (user.userMetadata?['name'] as String?);

      if (!mounted) return;
      setState(() {
        _fullName = (fullName != null && fullName.isNotEmpty)
            ? fullName
            : 'Name';
        _avatarUrl = (avatarUrl != null && avatarUrl.trim().isNotEmpty)
            ? avatarUrl.trim()
            : null;
        _phone = phone;
        _cnic = cnic;
        _address = address;
        _city = city;
        _stateProvince = stateProvince;
        _country = country;
        _email = email ?? user.email;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(45),
      child: AppBar(
        toolbarHeight: 45,
        backgroundColor: cs.primary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ManagerHome()),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          'Account',
          style: TextStyle(color: cs.onPrimary, fontSize: 20),
        ),
      ),
    );
  }

  Widget _profileHeaderCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.onPrimary,
            backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                ? NetworkImage(_avatarUrl!)
                : null,
            child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: cs.primary, size: 50)
                : null,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.person,
            text: _fullName ?? 'Full Name',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.badge,
            text: _cnic ?? 'CNIC',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.phone,
            text: _phone ?? 'Phone number',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.email_outlined,
            text: _email ?? 'Email',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.location_on,
            text: _address ?? 'Address',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.location_city,
            text: _city ?? 'City',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.map_outlined,
            text: _stateProvince ?? 'State/Province',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.flag_outlined,
            text: _country ?? 'Country',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    )
                    .then((_) => _loadUser());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.secondary,
                foregroundColor: cs.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
              child: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roField(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool isPrimaryOn = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isPrimaryOn ? cs.onPrimary : cs.onSurface).withOpacity(0.55),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: (isPrimaryOn ? cs.onPrimary : cs.onSurface).withOpacity(0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPrimaryOn ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? customColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: cs.onSurface.withOpacity(0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: customColor ?? cs.onSurface.withOpacity(0.85)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: customColor ?? cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: _appBar(context),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: Column(
                  children: [
                    _profileHeaderCard(context),
                    const SizedBox(height: 12),
                    _actionTile(
                      icon: Icons.phone_iphone_rounded,
                      label: 'Change Phone number',
                      onTap: () => Navigator.pushNamed(context, '/changePhone'),
                    ),
                    const SizedBox(height: 10),
                    _actionTile(
                      icon: Icons.alternate_email_rounded,
                      label: 'Change Email Address',
                      onTap: () => Navigator.pushNamed(context, '/changeEmail'),
                    ),
                    const SizedBox(height: 10),
                    _actionTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () =>
                          Navigator.pushNamed(context, '/changePassword'),
                    ),
                    const SizedBox(height: 10),
                    // 🔴 Logout tile with cs.error color
                    _actionTile(
                      icon: Icons.logout_rounded,
                      label: 'Log out',
                      customColor: cs.error,
                      onTap: () async {
                        await showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
