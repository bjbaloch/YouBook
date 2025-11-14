import 'package:flutter/material.dart';
import 'package:final_year_project/manager_home/manager_home.dart';
import 'package:final_year_project/services_details/bus_details/bus_details.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({Key? key}) : super(key: key);

  // ✅ Smooth page transition
  static PageRouteBuilder _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide =
            Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  // ✅ Back navigation
  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushReplacement(context, _smoothRoute(const ManagerHome()));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            backgroundColor: cs.primary,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  _smoothRoute(const ManagerHome()),
                );
              },
            ),
            title: Text(
              "Services",
              style: TextStyle(color: cs.onPrimary, fontSize: 20),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    "Select a service to add its details.",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ Service cards list (expandable)
                _serviceTile(
                  context,
                  "Add Bus details",
                  Icons.directions_bus_filled,
                  () {
                    Navigator.push(
                      context,
                      _smoothRoute(const AddBusDetailsScreen()),
                    );
                  },
                ),
                _serviceTile(
                  context,
                  "Add Van details",
                  Icons.airport_shuttle,
                  () {
                    Navigator.push(
                      context,
                      _smoothRoute(const VanDetailsPage()),
                    );
                  },
                ),

                // 🟩 Add more services easily here later
                // Example:
                // _serviceTile(context, "Taxi", Icons.local_taxi, () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Unified tile builder (same style as HelpSupportPage)
  Widget _serviceTile(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(icon, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: cs.onSurface, fontSize: 15),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Placeholder detail pages

class VanDetailsPage extends StatelessWidget {
  const VanDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        title: Text('Van Details', style: TextStyle(color: cs.onPrimary)),
      ),
      body: const Center(child: Text('Van details form goes here')),
    );
  }
}
