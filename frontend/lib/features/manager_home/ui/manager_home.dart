/// Manager Home UI - Manager home page
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/core/theme/app_colors.dart';
import 'package:final_year_project/features/manager_home/logic/manager_home_logic.dart';
import 'package:final_year_project/advertisement/advertisement.dart';
import 'package:final_year_project/side_bar_menu/side_bar_menu.dart';
import 'package:final_year_project/features/profile/ui/account.dart';
import 'package:final_year_project/notification/notification.dart';
import 'package:final_year_project/my_booking/my_booking.dart';
import 'package:final_year_project/support/help_support/help_support_page.dart';
import 'package:final_year_project/add_service/add_service_page.dart';
import 'package:final_year_project/wallet_section/youbook_wallet/wallet.dart';

class ManagerHome extends StatefulWidget {
  final double appBarHeight;
  final Widget? busIcon;
  final Widget? vanIcon;
  final Widget? bottomHomeIcon;
  final Widget? bottomBookingIcon;
  final Widget? bottomSupportIcon;
  final Widget? bottomWalletIcon;

  const ManagerHome({
    super.key,
    this.appBarHeight = 45,
    this.busIcon,
    this.vanIcon,
    this.bottomHomeIcon,
    this.bottomBookingIcon,
    this.bottomSupportIcon,
    this.bottomWalletIcon,
  });

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _displayName = "Guest";
  String? _email = "guest@example.com";
  String? _avatarUrl;
  bool _loadingProfile = false;

  DateTime? _lastBackPress;

  late final AnimationController _introCtrl;
  late final Animation<double> _introFade;
  late final Animation<Offset> _introSlide;

  late final ManagerHomeLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = ManagerHomeLogic(context: context);

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
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

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    final profile = await _logic.loadProfile();
    if (mounted) {
      setState(() {
        _displayName = profile.displayName;
        _email = profile.email;
        _avatarUrl = profile.avatarUrl;
        _loadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    super.dispose();
  }

  // Smooth page transition helper
  Route _smoothTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutCubic;
        final tween = Tween(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: curve));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }

  Widget _youBookTitle() {
    final cs = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 20),
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
                Navigator.push(context, _smoothTransition(const AccountPage()));
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
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                _smoothTransition(const ServicesPage()),
              );
            },
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

  Widget _adsCarousel() => const AdsCarousel(ads: []);

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

  Widget _bottomNav() {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      child: BottomNavigationBar(
        backgroundColor: cs.primary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: cs.onPrimary,
        unselectedItemColor: cs.onPrimary.withOpacity(0.9),
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) return;
          switch (i) {
            case 1:
              Navigator.pushReplacement(
                context,
                _smoothTransition(const MyBookingPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                _smoothTransition(const HelpSupportPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                _smoothTransition(const WalletPage()),
              );
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Column(
              children: [
                Container(
                  height: 3,
                  width: 25,
                  decoration: BoxDecoration(
                    color: cs.onPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3),
                widget.bottomHomeIcon ?? const Icon(Icons.home_rounded),
              ],
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: widget.bottomBookingIcon ?? const Icon(Icons.receipt_long),
            label: "Booking",
          ),
          BottomNavigationBarItem(
            icon: widget.bottomSupportIcon ?? const Icon(Icons.support_agent),
            label: "Support",
          ),
          BottomNavigationBarItem(
            icon:
                widget.bottomWalletIcon ??
                const Icon(Icons.account_balance_wallet),
            label: "Wallet",
          ),
        ],
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
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 27,
          ),
          onPressed: () {
            Navigator.push(
              context,
              _smoothTransition(const NotificationsPage()),
            );
          },
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 3),
      ],
    ),
  );

  Future<bool> _onWillPop() async {
    final shouldPop = _logic.handleBackPress(_lastBackPress);
    if (!shouldPop) {
      _lastBackPress = DateTime.now();
    }
    return shouldPop;
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
            isDarkMode: Theme.of(context).brightness == Brightness.dark,
            onThemeChanged: (v) {},
            selectedIndex: 0,
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
                child: ListView(
                  padding: const EdgeInsets.all(15),
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


