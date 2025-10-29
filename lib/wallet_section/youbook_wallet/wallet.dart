import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/manager_home/manager_home.dart';
import 'package:final_year_project/wallet_section/topup_wallet/topup_wallet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int selectedTab = 0; // 0 = Transactions, 1 = Pending
  bool _isLoading = false; // Loading state for the top-up button

  final List<Map<String, dynamic>> transactions = [];
  final List<Map<String, dynamic>> pending = [];

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ManagerHome()),
    );
    return false; // Prevents default back action
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const double balance = 0.00;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: AppColors.lightSeaGreen,
          toolbarHeight: 45,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textWhite,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ManagerHome()),
              );
            },
          ),
          title: const Text(
            "Welcome to YouBook Wallet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          centerTitle: true,
        ),

        // ================= BODY ==================
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // ===== Wallet Balance Card =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9B44), Color(0xFFFF6433)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Wallet Balance",
                      style: TextStyle(
                        color: AppColors.hintWhite,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "PKR ${balance.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // ===== Top-up Button (Fixed Navigation) =====
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.lightSeaGreen
                        : Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);

                          // Optional: short delay for UX
                          await Future.delayed(const Duration(seconds: 1));

                          if (!mounted) return;

                          // ✅ Navigate and wait until user returns
                          await Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const TopupAccountsPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeOutCubic;

                                    final tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                          );

                          if (!mounted) return;
                          // Reset loading state after navigation completes
                          setState(() => _isLoading = false);
                        },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.textWhite,
                            ),
                          )
                        : const Text(
                            "Add / Top-up YouBook Wallet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ===== Tabs (Transaction / Pending) =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton("Transaction History", 0, cs),
                  _buildTabButton("Pending", 1, cs),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Divider(
                  thickness: 1,
                  color: isDark
                      ? AppColors.textWhite.withOpacity(0.15)
                      : AppColors.textBlack.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 20),

              // ===== Empty Placeholder =====
              Expanded(
                child: Center(
                  child: Text(
                    selectedTab == 0
                        ? "No transactions yet."
                        : "No pending items.",
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Helper: Tab Button Builder =====
  Widget _buildTabButton(String label, int index, ColorScheme cs) {
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selectedTab == index
                  ? cs.onSurface
                  : cs.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 3),
          if (selectedTab == index)
            SizedBox(
              width: label == "Pending" ? 60 : 70,
              child: const Divider(thickness: 3, color: AppColors.accentOrange),
            ),
        ],
      ),
    );
  }
}
