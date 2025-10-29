import 'dart:async';
import 'package:final_year_project/wallet_section/youbook_wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/side_bar_menu/logout_confirm.dart';
import 'package:final_year_project/profile/account/account.dart';
import 'package:final_year_project/notification/notification.dart';
import 'package:final_year_project/my_booking/my_booking.dart';
import 'package:final_year_project/manager_home/manager_home.dart';
import 'package:final_year_project/support/help_support/help_support_page.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class AppSidebarDrawer extends StatefulWidget {
  const AppSidebarDrawer({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
    this.selectedIndex = 0,
    this.onLogout,
    this.showVersion = true,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final int selectedIndex;
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
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final user = _sb.auth.currentUser;
      setState(() => _loading = true);

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
        _email = email ?? user.email;
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
      } finally {
        if (!mounted) return;
        if (widget.onLogout != null) {
          widget.onLogout!();
        }
      }
    }
  }

  PageRouteBuilder _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        final slide =
            Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
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
          // ✅ Theme toggle row
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() => _localIsDark = !_localIsDark);
                  widget.onThemeChanged(_localIsDark);
                  AppTheme.setDark(_localIsDark);
                },
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      _localIsDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      key: ValueKey(_localIsDark),
                      color: cs.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Switch.adaptive(
                  key: ValueKey(_localIsDark),
                  value: _localIsDark,
                  activeColor: cs.secondary,
                  onChanged: (v) {
                    setState(() => _localIsDark = v);
                    widget.onThemeChanged(v);
                    AppTheme.setDark(v);
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
                    ? const SizedBox(
                        height: 36,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
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

  Widget _navItem({
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.pushReplacement(context, _smoothRoute(page));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurface),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: cs.onBackground,
                fontWeight: FontWeight.w500,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Drawer(
        backgroundColor: cs.background, // ✅ Same background as other pages
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Column(
                        children: [
                          _navItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            page: const ManagerHome(),
                          ),
                          _navItem(
                            icon: Icons.person_rounded,
                            label: 'Account',
                            page: const AccountPage(),
                          ),
                          _navItem(
                            icon: Icons.notifications_none_rounded,
                            label: 'Notifications',
                            page: const NotificationsPage(),
                          ),
                          _navItem(
                            icon: Icons.card_travel_rounded,
                            label: 'Booking',
                            page: const MyBookingPage(),
                          ),
                          _navItem(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Wallet',
                            page: const WalletPage(),
                          ),
                          _navItem(
                            icon: Icons.support_agent_rounded,
                            label: 'Support',
                            page: const HelpSupportPage(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ✅ Logout styled same as upper card
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _confirmAndLogout,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: cs.error),
                              const SizedBox(width: 14),
                              Text('Logout', style: TextStyle(color: cs.error)),
                            ],
                          ),
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
      ),
    );
  }
}
