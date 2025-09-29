import 'package:final_year_project/support/about_app/about_app.dart';
import 'package:final_year_project/support/faqs/faqs.dart';
import 'package:final_year_project/support/privacy_policy/privacy_policy.dart';
import 'package:final_year_project/support/terms_condition/terms_conditions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/support/feedback/feedback_popup.dart'; // ✅ Correct Feedback popup import
import 'package:final_year_project/manager_home/manager_home.dart';
import 'package:final_year_project/app_images/app_images.dart'; // ✅ centralized images

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  // ✅ Smooth route helper
  static PageRouteBuilder _smoothRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
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

  Widget _supportTile(
    BuildContext context,
    String label,
    String assetPath,
    VoidCallback onTap,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                child: Image.asset(assetPath, fit: BoxFit.contain),
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          toolbarHeight: 45,
          backgroundColor: cs.primary,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacement(_smoothRoute(const ManagerHome()));
            },
          ),
          centerTitle: true,
          title: Text(
            "Help & Support",
            style: TextStyle(
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "We are here to help you !",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Support tiles with centralized image paths
            // contact us
            _supportTile(context, "Contact Us", AppImages.contact, () {}),

            //FAQs
            _supportTile(context, "FAQs", AppImages.faq, () {
              Navigator.of(context).push(_smoothRoute(const FAQsPage()));
            }),

            // terms and conditions
            _supportTile(context, "Terms & Conditions", AppImages.terms, () {
              Navigator.of(
                context,
              ).push(_smoothRoute(const TermsAndConditionsPage()));
            }),

            //privacy policy
            _supportTile(context, "Privacy Policy", AppImages.privacy, () {
              Navigator.of(
                context,
              ).push(_smoothRoute(const PrivacyPolicyPage()));
            }),

            // About app
            _supportTile(context, "About App", AppImages.about, () {
              Navigator.of(context).push(_smoothRoute(const AboutAppPage()));
            }),

            //invite friend
            _supportTile(context, "Invite Friend", AppImages.invite, () {}),

            // rate app
            _supportTile(context, "Rate App", AppImages.rate, () {}),

            // feedback popup function
            _supportTile(context, "Feedback", AppImages.feedback, () {
              showFeedbackPopup(context);
            }),
          ],
        ),
      ),
    );
  }
}
