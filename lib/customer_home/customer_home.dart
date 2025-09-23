// SECTION: Imports
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for SystemUiOverlayStyle
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/advertisement/advertisement.dart';
import 'package:final_year_project/side_bar_menu/side_bar_menu.dart';

// SECTION: Home (Manager) - with editable AppBar height and icon slots
class CustomerHome extends StatefulWidget {
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

  const CustomerHome({
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
  State<CustomerHome> createState() => _HomePageState();
}

class _HomePageState extends State<CustomerHome>
    with SingleTickerProviderStateMixin {
  // SECTION: Keys and controllers
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // SECTION: Supabase user profile state
  String? _displayName;
  String? _email;
  bool _loadingProfile = false;
  StreamSubscription<AuthState>? _authSub;

  // SECTION: Double-back-to-exit
  DateTime? _lastBackPress;

  // SECTION: Bottom navigation state
  int _currentIndex = 0;

  // SECTION: First-time intro animation (smooth entrance from user selection)
  late final AnimationController _introCtrl;
  late final Animation<double> _introFade;
  late final Animation<Offset> _introSlide;

  @override
  void initState() {
    super.initState();

    // Intro animation
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

    // SECTION: User profile load + auth state subscription
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

  // SECTION: Route helper (smooth transitions if you navigate)
  // ignore: unused_element
  Route<T> _route<T>(Widget page) => PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final fade = Tween<double>(begin: 0, end: 1).animate(curved);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.05),
        end: Offset.zero,
      ).animate(curved);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );

  // SECTION: Load user profile from Supabase
  Future<void> _loadUser() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;

      if (!mounted) return;
      setState(() {
        _email = user?.email;
        _loadingProfile = true;
      });

      if (user == null) {
        setState(() {
          _displayName = null;
          _loadingProfile = false;
        });
        return;
      }

      String? fullName;
      try {
        final data = await client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .limit(1);
        if (data.isNotEmpty) {
          final first = data.first;
          fullName = (first['full_name'] as String?)?.trim();
        }
      } catch (_) {
        // ignore if profiles table/row not found
      }

      fullName ??=
          (user.userMetadata?['full_name'] as String?) ??
          (user.userMetadata?['name'] as String?);

      if (!mounted) return;
      setState(() {
        _displayName = (fullName != null && fullName.isNotEmpty)
            ? fullName
            : 'Name';
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _displayName = null;
        _loadingProfile = false;
      });
    }
  }

  // SECTION: Title widget (logo text)
  Widget _youBookTitle() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(fontSize: 22),
        children: [
          TextSpan(
            text: "Y",
            style: TextStyle(color: AppColors.textWhite),
          ),
          TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          TextSpan(
            text: "U",
            style: TextStyle(color: AppColors.textWhite),
          ),
          TextSpan(
            text: "B",
            style: TextStyle(color: AppColors.textWhite),
          ),
          TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          TextSpan(
            text: "O",
            style: TextStyle(color: AppColors.logoYellow),
          ),
          TextSpan(
            text: "K",
            style: TextStyle(color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }

  // SECTION: Top quick actions card (Add your service section removed)
  Widget _quickActionCard(BuildContext context) {
    final name = _displayName ?? 'Name';
    final email = _email ?? 'Email address';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSeaGreen,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                // SECTION: Navigation placeholder - Profile
                // Navigator.pushNamed(context, '/profile');
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.textWhite,
                    child: Icon(
                      Icons.person,
                      color: AppColors.lightSeaGreen,
                      size: 30, // bigger
                    ),
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
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Removed divider and "Add your service" button
        ],
      ),
    );
  }

  // SECTION: Advertisements (embedded, not clickable; owner sets content in advertisement.dart)
  Widget _adsCarousel() {
    return const AdsCarousel(ads: []);
  }

  // SECTION: Category tile (Bus/Van) - icon slot supported
  Widget _categoryTile({
    required String title,
    required VoidCallback onTap,
    Widget?
    icon, // pass your own icon widget via widget.busIcon or widget.vanIcon
  }) {
    return Material(
      color: AppColors.hintWhite,
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
              icon ??
                  const Icon(
                    Icons.directions_bus,
                    color: AppColors.lightSeaGreen,
                    size: 40, // bigger
                  ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: decorate bottom nav icon with underline + hold effect
  Widget _decorateNavIcon(Widget icon, bool selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: selected ? 1.12 : 1.0, // subtle effect when staying on page
          curve: Curves.easeOutCubic,
          child: icon,
        ),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 2,
          width: selected ? 20 : 0, // horizontal indicator line
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }

  // SECTION: Bottom navigation with customizable icons + ripple + underline indicator
  Widget _bottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightSeaGreen,
        borderRadius: BorderRadius.only(
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
          // Ripple effect for each tap
          data: Theme.of(context).copyWith(
            splashFactory: InkRipple.splashFactory,
            splashColor: Colors.white24,
            highlightColor: Colors.white12,
          ),
          child: BottomNavigationBar(
            backgroundColor: AppColors.lightSeaGreen,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.textWhite,
            unselectedItemColor: AppColors.textWhite.withOpacity(0.9),
            // Larger icons
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

  // SECTION: Editable AppBar (edit only here) + Status bar separation
  PreferredSizeWidget _editableAppBar() => PreferredSize(
    preferredSize: Size.fromHeight(widget.appBarHeight),
    child: AppBar(
      toolbarHeight: widget.appBarHeight, // edit height via widget.appBarHeight
      backgroundColor: AppColors.lightSeaGreen,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: AppColors.background,
          size: 30, // bigger
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      centerTitle: true,
      title: _youBookTitle(),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: AppColors.background,
            size: 27, // bigger
          ),
          onPressed: () {
            // Navigator.pushNamed(context, '/notifications');
          },
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 3),
      ],
    ),
  );

  // SECTION: Handle double back press to exit
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
    return true; // exit app
  }

  // SECTION: Map bottom tab index -> drawer selected
  int _drawerSelectedFromTab(int tab) {
    switch (tab) {
      case 0:
        return 0; // Home
      case 1:
        return 3; // Booking
      case 2:
        return 5; // Support
      case 3:
        return 4; // Wallet
      default:
        return 0;
    }
  }

  // SECTION: Handle sidebar selections -> update tabs or navigate
  void _onSidebarItemSelected(int i) {
    // 0: Home, 1: Account, 2: Notifications, 3: Booking, 4: Wallet, 5: Support
    switch (i) {
      case 0:
        setState(() => _currentIndex = 0);
        break;
      case 1:
        Navigator.pushNamed(context, '/account');
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications');
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

  // SECTION: Per-tab bodies (Home + placeholders)
  Widget _pageBody(int index) {
    switch (index) {
      case 0:
        // Home page
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
                    onTap: () {
                      // Navigator.pushNamed(context, '/busTickets');
                    },
                    icon:
                        widget.busIcon, // <-- your custom bus icon if provided
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: _categoryTile(
                    title: "Van Tickets",
                    onTap: () {
                      // Navigator.pushNamed(context, '/vanTickets');
                    },
                    // Real van icon fallback
                    icon:
                        widget.vanIcon ??
                        const Icon(
                          Icons.airport_shuttle,
                          color: AppColors.lightSeaGreen,
                          size: 40,
                        ),
                  ),
                ),
              ],
            ),
          ],
        );
      case 1:
        // Booking placeholder
        return const Center(key: ValueKey('booking'), child: SizedBox.shrink());
      case 2:
        // Support placeholder
        return const Center(key: ValueKey('support'), child: SizedBox.shrink());
      case 3:
      default:
        // Wallet placeholder
        return const Center(key: ValueKey('wallet'), child: SizedBox.shrink());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with AnnotatedRegion for system UI styling separation
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,

          // SECTION: Drawer (use your existing sidebar.dart widget)
          drawer: AppSidebarDrawer(
            isDarkMode: AppTheme.mode.value == ThemeMode.dark,
            onThemeChanged: (v) => AppTheme.setDark(v),
            selectedIndex: _drawerSelectedFromTab(_currentIndex),
            onItemSelected: _onSidebarItemSelected,
            onLogout: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/userSelection', (r) => false);
            },
          ),

          // SECTION: AppBar (single editable section)
          appBar: _editableAppBar(),

          // SECTION: Body with intro + smooth per-page transitions
          body: SafeArea(
            child: FadeTransition(
              opacity: _introFade,
              child: SlideTransition(
                position: _introSlide,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    final fade = CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOutCubic,
                    );
                    final slide =
                        Tween<Offset>(
                          begin: const Offset(0, 0.04),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                    return FadeTransition(
                      opacity: fade,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: _pageBody(_currentIndex),
                ),
              ),
            ),
          ),

          // SECTION: Bottom Navigation
          bottomNavigationBar: _bottomNav(),
        ),
      ),
    );
  }
}
