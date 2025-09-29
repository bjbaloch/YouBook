import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/manager_home/manager_home.dart';

class MyBookingPage extends StatefulWidget {
  const MyBookingPage({super.key});

  @override
  State<MyBookingPage> createState() => _MyBookingPageState();
}

class _MyBookingPageState extends State<MyBookingPage> {
  bool isBusSelected = true; // toggle between Bus & Van
  bool isPaidSelected = true; // toggle between Paid & Unpaid

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: cs.primary,
          elevation: 0,
          centerTitle: true, // ✅ center the title
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          title: Text(
            "My Booking",
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ManagerHome()),
              );
            },
          ),
        ),
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),

            // --- Bus / Van Tabs (Full width, expandable row) ---
            Container(
              width: double.infinity,
              color: AppColors.lightOrange, // ✅ background
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTab(
                    label: "Bus",
                    icon: Icons.directions_bus,
                    selected: isBusSelected,
                    cs: cs,
                    onTap: () => setState(() => isBusSelected = true),
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    label: "Van",
                    icon: Icons.airport_shuttle,
                    selected: !isBusSelected,
                    cs: cs,
                    onTap: () => setState(() => isBusSelected = false),
                  ),
                  // ✅ Future expandable: just add more tabs here
                ],
              ),
            ),

            const SizedBox(height: 5),

            // === Paid / Unpaid Round Tabs ===
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(
                        Icons.check_circle,
                        color: AppColors.successGreen,
                      ),
                      label: const Text("Paid"),
                      selected: isPaidSelected,
                      selectedColor: cs.primary,
                      labelStyle: TextStyle(
                        color: isPaidSelected ? cs.onPrimary : cs.onSurface,
                      ),
                      onSelected: (_) => setState(() => isPaidSelected = true),
                      shape: const StadiumBorder(),
                    ),
                  ),
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(
                        Icons.timelapse_rounded,
                        color: AppColors.error,
                      ),
                      label: const Text("Unpaid"),
                      selected: !isPaidSelected,
                      selectedColor: cs.primary,
                      labelStyle: TextStyle(
                        color: !isPaidSelected ? cs.onPrimary : cs.onSurface,
                      ),
                      onSelected: (_) => setState(() => isPaidSelected = false),
                      shape: const StadiumBorder(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // === Empty Booking Illustration / Message ===
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    key: ValueKey("${isBusSelected}_${isPaidSelected}"),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.6, // ✅ PNG with opacity
                        child: Image.asset(
                          isBusSelected
                              ? "assets/bus/bus_icon.png"
                              : "assets/van/van_icon.png",
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isPaidSelected
                            ? "There is no any paid booking at the moment."
                            : "There is no any unpaid booking at the moment.",
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget to build a tab (Bus / Van / Future tabs)
  Widget _buildTab({
    required String label,
    required IconData icon,
    required bool selected,
    required ColorScheme cs,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent, // ✅ highlight
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
