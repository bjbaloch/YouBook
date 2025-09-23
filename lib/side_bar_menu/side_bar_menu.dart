import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/side_bar_menu/logout_confirm.dart'; // logout popup import
import 'package:final_year_project/Login/login_page.dart'; // direct login import
import 'package:final_year_project/profile/account.dart'; // direct Account page import
import 'package:final_year_project/notification/notification.dart';

class AppSidebarDrawer extends StatefulWidget {
  const AppSidebarDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    this.selectedIndex = 0, // 0: Home, 1: Account, etc.
    required this.onItemSelected,
    this.onLogout,
    this.showVersion = true,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final int selectedIndex;
  final void Function(int index) onItemSelected;
  final VoidCallback? onLogout;
  final bool showVersion;

  @override
  State<AppSidebarDrawer> createState() => _AppSidebarDrawerState();
}

class _AppSidebarDrawerState extends State<AppSidebarDrawer> {
  String? _displayName;
  String? _email;
  String? _avatarUrl;
  bool _loading = false;
  StreamSubscription<AuthState>? _authSub;
  late bool _localIsDark;

  SupabaseClient get _sb => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _localIsDark = widget.isDarkMode;
    _loadUser();
    _authSub = _sb.auth.onAuthStateChange.listen((_) => _loadUser());
  }

  @override
  void didUpdateWidget(covariant AppSidebarDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _localIsDark = widget.isDarkMode;
    }
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
          _displayName = null;
          _avatarUrl = null;
          _email = null;
          _loading = false;
        });
        return;
      }

      String? fullName;
      String? avatarUrl;
      String? email;

      try {
        final data = await _sb
            .from('profiles')
            .select('full_name, avatar_url, email')
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          fullName = (data['full_name'] as String?)?.trim();
          avatarUrl = (data['avatar_url'] as String?)?.trim();
          email = (data['email'] as String?)?.trim();
        }
      } catch (e) {
        debugPrint("Error fetching profile: $e");
      }

      if (!mounted) return;
      setState(() {
        _displayName = (fullName != null && fullName.isNotEmpty)
            ? fullName
            : 'Name';
        _avatarUrl = (avatarUrl != null && avatarUrl.isNotEmpty)
            ? avatarUrl
            : null;
        _email = email ?? user.email; // fallback to auth.users
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndLogout() async {
    final result = await showLogoutDialog(context);
    if (result == true) {
      try {
        await _sb.auth.signOut();
      } catch (_) {
      } finally {
        if (!mounted) return;
        if (widget.onLogout != null) {
          widget.onLogout!();
        } else {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      }
    }
  }

  Widget _header() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 170),
      color: cs.primary,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme toggle row
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() => _localIsDark = !_localIsDark);
                  widget.onThemeChanged(_localIsDark);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    _localIsDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: cs.onPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Transform.scale(
                scale: 0.9,
                child: Switch.adaptive(
                  value: _localIsDark,
                  activeColor: cs.secondary,
                  onChanged: (v) {
                    setState(() => _localIsDark = v);
                    widget.onThemeChanged(v);
                  },
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: cs.onPrimary,
                ),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Profile row
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: cs.onPrimary,
                backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? NetworkImage(_avatarUrl!)
                    : null,
                child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                    ? Icon(Icons.person, color: cs.primary, size: 40)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _loading
                    ? SizedBox(
                        height: 36,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.onPrimary,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName ?? 'Name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _email ?? 'Email address',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onPrimary.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required int index,
    Color? iconColor,
  }) {
    final selected = widget.selectedIndex == index;
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        if (index == 1) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AccountPage()));
        } else if (index == 2) {
          // ✅ Navigate to NotificationsPage
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
        } else {
          widget.onItemSelected(index);
        }
      },
      splashColor: cs.primary.withOpacity(0.10),
      highlightColor: cs.primary.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? cs.onSurface.withOpacity(0.7)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: cs.onBackground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 6,
              width: selected ? 6 : 0,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _tile(icon: Icons.home_rounded, label: 'Home', index: 0),
                  _tile(icon: Icons.person_rounded, label: 'Account', index: 1),
                  _tile(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    index: 2,
                  ),
                  _tile(
                    icon: Icons.card_travel_rounded,
                    label: 'Booking',
                    index: 3,
                  ),
                  _tile(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    index: 4,
                  ),
                  _tile(
                    icon: Icons.support_agent_rounded,
                    label: 'Support',
                    index: 5,
                  ),
                  InkWell(
                    onTap: _confirmAndLogout,
                    splashColor: cs.primary.withOpacity(0.1),
                    highlightColor: cs.primary.withOpacity(0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: cs.error),
                          const SizedBox(width: 14),
                          Text(
                            'Logout',
                            style: TextStyle(color: cs.onBackground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showVersion)
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 6),
                child: Text(
                  'Version',
                  style: TextStyle(
                    color: cs.onBackground.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
