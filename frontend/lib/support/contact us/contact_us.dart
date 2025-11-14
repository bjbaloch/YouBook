import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:final_year_project/support/help_support/help_support_page.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  // ===== Launchers =====
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");
    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request&body=Hello Support Team,',
    );
    if (!await launchUrl(emailUrl)) {
      throw 'Could not launch $emailUrl';
    }
  }

  Widget _contactCard({
    required BuildContext context,
    required String title,
    required String description,
    required String detail,
    required String buttonText,
    required String assetIcon,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center align
          children: [
            // Centered icon + title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(assetIcon, height: 28, width: 28),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textWhite : AppColors.textBlack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textWhite : AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 4),

            // Centered detail (Phone/Email/WhatsApp)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 18, color: AppColors.blue),
                const SizedBox(width: 6),
                Text(detail, style: const TextStyle(color: AppColors.blue)),
              ],
            ),

            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onPressed,
                child: Text(buttonText, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String phoneNumber = "03171292355";
    const String email = "youbook210@gmail.com";
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HelpSupportPage()),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          "Contact Us",
          style: TextStyle(
            color: cs.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 6),
            child: Text(
              "Contact to our support team directly.",
              style: TextStyle(color: cs.onSurface),
            ),
          ),

          // Call Card
          _contactCard(
            context: context,
            title: "Call Us",
            description: "Call our support team directly.",
            detail: "Phone : $phoneNumber",
            buttonText: "Call Now",
            assetIcon: "assets/support/contact_us_icon.png",
            onPressed: () => _launchPhone(phoneNumber),
          ),

          // WhatsApp Card
          _contactCard(
            context: context,
            title: "WhatsApp",
            description: "Chat with our support team on WhatsApp.",
            detail: "WhatsApp : $phoneNumber",
            buttonText: "Chat Now",
            assetIcon: "assets/support/whatsapp_icon.png",
            onPressed: () => _launchWhatsApp(phoneNumber),
          ),

          // Email Card
          _contactCard(
            context: context,
            title: "Email",
            description: "Email our support team they will reach you soon.",
            detail: "Email : $email",
            buttonText: "Email Now",
            assetIcon: "assets/support/email_icon.png",
            onPressed: () => _launchEmail(email),
          ),
        ],
      ),
    );
  }
}
