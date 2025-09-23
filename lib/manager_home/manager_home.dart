// 📂 manager_home.dart
// SECTION: Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for SystemUiOverlayStyle
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/advertisement/advertisement.dart';
import 'package:final_year_project/side_bar_menu/side_bar_menu.dart';
import 'package:final_year_project/profile/account.dart';
import 'package:final_year_project/notification/notification.dart';

// SECTION: Home (Manager) - with editable AppBar height and icon slots
class ManagerHome extends StatefulWidget {
  // Editable AppBar height
  final double appBarHeight;

  // Icon slots you can pass in
  final Widget? busIcon;
  final Widget? vanIcon;

  // Bottom bar icon slots
  final Widget? bottomHomeIcon;
  final Widget? bottomBookingIcon;
  final Widget? bottomSupportIcon;
  final Widget? bottomWalletIcon;

  const ManagerHome({
    super.key,
    this.appBarHeight = 45, // default AppBar height
    this.busIcon,
    this.vanIcon,
    this.bottomHomeIcon,
    this.bottomBookingIcon,
    this.bottomSupportIcon,
    this.bottomWalletIcon,
  });

  @override
  State<ManagerHome> createState() => _HomePageState();
}

class _HomePageState extends State<ManagerHome>
    with SingleTickerProviderStateMixin {
  // SECTION: Keys and controllers
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // SECTION: Supabase user profile state
  String? _displayName;
  String? _email;
  String? _avatarUrl;
  bool _loadingProfile = false;
  StreamSubscription<AuthState>? _authSub;

  // SECTION: Double-back-to-exit
  DateTime? _lastBackPress;

  // SECTION: Bottom navigation state
  int _currentIndex = 0;

  // SECTION: First-time intro animation
  late final AnimationController _introCtrl;
  late final Animation<double> _introFade;
  late final Animation<Offset> _introSlide;

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _introFade = CurvedAnimation(
      parent: _introCtrl,
      curve: Curves.easeOutCubic,
    );
    _introSlide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic));
    _introCtrl.forward();

    // User profile load + auth state subscription
    _loadUser();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (_) => _loadUser(),
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _introCtrl.dispose();
    super.dispose();
  }

  // Load user profile from Supabase
  Future<void> _loadUser() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (!mounted) return;
      setState(() {
        _loadingProfile = true;
      });

      if (user == null) {
        setState(() {
          _displayName = null;
          _avatarUrl = null;
          _email = null;
          _loadingProfile = false;
        });
        return;
      }

      String? fullName;
      String? avatarUrl;
      String? email;

      try {
        final data = await client
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
        debugPrint("Profile fetch error: $e");
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
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _displayName = null;
        _avatarUrl = null;
        _email = null;
        _loadingProfile = false;
      });
    }
  }

  // Title widget
  Widget _youBookTitle() {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 22),
        children: [
          TextSpan(
            text: "Y",
            style: TextStyle(color: cs.onPrimary),
          ),
          const TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          TextSpan(
            text: "U",
            style: TextStyle(color: cs.onPrimary),
          ),
          TextSpan(
            text: "B",
            style: TextStyle(color: cs.onPrimary),
          ),
          const TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          const TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          TextSpan(
            text: "K",
            style: TextStyle(color: cs.onPrimary),
          ),
        ],
      ),
    );
  }

  // Quick actions card (account + services)
  Widget _quickActionCard(BuildContext context) {
    final name = _displayName ?? 'Name';
    final email = _email ?? 'Email address';
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AccountPage()));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: cs.onPrimary,
                    backgroundImage:
                        (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                        ? Icon(Icons.person, color: cs.primary, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loadingProfile ? 'Loading...' : name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: cs.onPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 35,
            width: 2,
            color: cs.onPrimary,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).colorScheme.secondary,
              size: 40,
            ),
            label: Text(
              "Add\nyour service",
              style: TextStyle(color: cs.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // Ads Carousel
  Widget _adsCarousel() {
    return const AdsCarousel(ads: []);
  }

  // Category Tile
  Widget _categoryTile({
    required String title,
    required VoidCallback onTap,
    Widget? icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon ?? Icon(Icons.directions_bus, color: cs.primary, size: 40),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _decorateNavIcon(Widget icon, bool selected) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: selected ? 1.12 : 1.0,
          curve: Curves.easeOutCubic,
          child: icon,
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 2,
          width: selected ? 20 : 0,
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: InkRipple.splashFactory,
            splashColor: cs.onPrimary.withOpacity(0.24),
            highlightColor: cs.onPrimary.withOpacity(0.12),
          ),
          child: BottomNavigationBar(
            backgroundColor: cs.primary,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: cs.onPrimary,
            unselectedItemColor: cs.onPrimary.withOpacity(0.9),
            selectedIconTheme: const IconThemeData(size: 30),
            unselectedIconTheme: const IconThemeData(size: 30),
            currentIndex: _currentIndex,
            onTap: (i) {
              if (i == _currentIndex) return;
              setState(() => _currentIndex = i);
            },
            items: [
              BottomNavigationBarItem(
                icon: _decorateNavIcon(
                  widget.bottomHomeIcon ?? const Icon(Icons.home_rounded),
                  _currentIndex == 0,
                ),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: _decorateNavIcon(
                  widget.bottomBookingIcon ?? const Icon(Icons.receipt_long),
                  _currentIndex == 1,
                ),
                label: "Booking",
              ),
              BottomNavigationBarItem(
                icon: _decorateNavIcon(
                  widget.bottomSupportIcon ?? const Icon(Icons.support_agent),
                  _currentIndex == 2,
                ),
                label: "Support",
              ),
              BottomNavigationBarItem(
                icon: _decorateNavIcon(
                  widget.bottomWalletIcon ??
                      const Icon(Icons.account_balance_wallet),
                  _currentIndex == 3,
                ),
                label: "Wallet",
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _editableAppBar() => PreferredSize(
    preferredSize: Size.fromHeight(widget.appBarHeight),
    child: AppBar(
      toolbarHeight: widget.appBarHeight,
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: Icon(
          Icons.menu,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 30,
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      centerTitle: true,
      title: _youBookTitle(),
      actions: [
        // ✅ Notifications Navigation Added Here
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 27,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 3),
      ],
    ),
  );

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
      }
      return false;
    }
    return true;
  }

  int _drawerSelectedFromTab(int tab) {
    switch (tab) {
      case 0:
        return 0;
      case 1:
        return 3;
      case 2:
        return 5;
      case 3:
        return 4;
      default:
        return 0;
    }
  }

  void _onSidebarItemSelected(int i) {
    switch (i) {
      case 0:
        setState(() => _currentIndex = 0);
        break;
      case 1:
        Navigator.pushNamed(context, '/account');
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
        break;
      case 3:
        setState(() => _currentIndex = 1);
        break;
      case 4:
        setState(() => _currentIndex = 3);
        break;
      case 5:
        setState(() => _currentIndex = 2);
        break;
    }
  }

  Widget _pageBody(int index) {
    final cs = Theme.of(context).colorScheme;
    switch (index) {
      case 0:
        return ListView(
          key: const ValueKey('home'),
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          children: [
            _quickActionCard(context),
            const SizedBox(height: 15),
            _adsCarousel(),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _categoryTile(
                    title: "Bus Tickets",
                    onTap: () {},
                    icon: widget.busIcon,
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: _categoryTile(
                    title: "Van Tickets",
                    onTap: () {},
                    icon:
                        widget.vanIcon ??
                        Icon(
                          Icons.airport_shuttle,
                          color: cs.primary,
                          size: 40,
                        ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 1:
        return const Center(key: ValueKey('booking'), child: SizedBox.shrink());
      case 2:
        return const Center(key: ValueKey('support'), child: SizedBox.shrink());
      case 3:
      default:
        return const Center(key: ValueKey('wallet'), child: SizedBox.shrink());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: cs.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: cs.background,
          drawer: AppSidebarDrawer(
            isDarkMode: AppTheme.mode.value == ThemeMode.dark,
            onThemeChanged: (v) => AppTheme.setDark(v),
            selectedIndex: _drawerSelectedFromTab(_currentIndex),
            onItemSelected: _onSidebarItemSelected,
            onLogout: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (r) => false);
            },
          ),
          appBar: _editableAppBar(),
          body: SafeArea(
            child: FadeTransition(
              opacity: _introFade,
              child: SlideTransition(
                position: _introSlide,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _pageBody(_currentIndex),
                ),
              ),
            ),
          ),
          bottomNavigationBar: _bottomNav(),
        ),
      ),
    );
  }
}
