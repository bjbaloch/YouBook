import 'dart:io'; // for SocketException
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // added for SystemNavigator.pop
import 'package:supabase_flutter/supabase_flutter.dart';
import 'forget_password_popup.dart';
import 'package:final_year_project/Signup/signup_page.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/manager_home/manager_home.dart';
//import 'package:final_year_project/customer_home/customer_home.dart';

/// ─────────────────────────────────────────────────────────────
/// LOGIN PAGE
/// ─────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Track back presses for exit-on-double-back
  DateTime? _lastBackPressTime;

  // Helper to detect network errors across platforms
  bool _isNetworkError(dynamic e) {
    if (e is SocketException) return true;
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('host lookup') ||
        msg.contains('failed host lookup') ||
        msg.contains('socket') ||
        msg.contains('timed out') ||
        msg.contains('xmlhttprequest') || // web
        msg.contains('failed to fetch'); // web
  }

  // Handle double back press to exit
  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // don't pop yet
    }
    // Exit app on second press
    SystemNavigator.pop();
    return false;
  }

  // ✅ Function to handle Login with smooth delay
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2)); // 🔹 Smooth loading

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session != null) {
        // Ensure a profiles row exists/up-to-date on login
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser != null) {
          try {
            await Supabase.instance.client.from('profiles').upsert({
              'id': authUser.id,
              'email': authUser.email,
              'full_name':
                  (authUser.userMetadata?['full_name'] as String?) ??
                  (authUser.userMetadata?['name'] as String?),
              'phone': authUser.userMetadata?['phone'],
              'cnic': authUser.userMetadata?['cnic'],
              'updated_at': DateTime.now().toIso8601String(),
            }).select();
          } catch (_) {
            // ignore upsert fallback errors
          }
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("✅ Login successful!")));

        // ── Navigate based on role in profiles.role ─────────────
        final user = Supabase.instance.client.auth.currentUser;
        String? role;
        try {
          final Map<String, dynamic>? profile = await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', user!.id)
              .maybeSingle();
          role = (profile?['role'] as String?)?.toLowerCase().trim();
        } catch (_) {
          role = null; // fallback to default if query fails
        }

        if (!mounted) return;

        if (role == 'manager') {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ManagerHome()),
            (route) => false,
          );
        } else {
          // Default to customer/passenger home
          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(builder: (_) => const CustomerHome()),
          //   (route) => false,
          // );
        }
        // ─────────────────────────────────────────────────────────────
      }
    } on SocketException {
      // Real internet error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No internet connection. Please check your network."),
        ),
      );
    } on AuthException catch (e) {
      // Invalid credentials and other auth errors
      if (_isNetworkError(e)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No internet connection. Please check your network."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Invalid email or password")),
        );
      }
    } catch (e) {
      // Fallback for other errors (including web network variants)
      if (_isNetworkError(e)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No internet connection. Please check your network."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Invalid email or password")),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      // Exit app on double back press
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false, // ✅ Prevents layout shift on keyboard
        backgroundColor: cs.background,
        body: Stack(
          children: [
            // 🔹 Main content (scrollable if needed)
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                bottom: 180,
              ), // space for bottom bar
              child: Column(
                children: [
                  // 🔹 Green Header with Rounded Bottom (auto-fit height)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔹 YOUBOOK text with separate colors
                        RichText(
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
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Login to your account",
                          style: TextStyle(fontSize: 15, color: cs.onPrimary),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Form with Validation
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: cs.secondary,
                                cursorWidth: 2,
                                cursorRadius: const Radius.circular(2),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your email";
                                  }
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(value)) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: cs.onPrimary.withOpacity(0.75),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hintStyle: TextStyle(
                                    color: cs.onPrimary.withOpacity(0.75),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: cs.secondary),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: cs.secondary,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: TextStyle(color: cs.error),
                                ),
                                style: TextStyle(color: cs.onPrimary),
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                cursorColor: cs.secondary,
                                cursorWidth: 2,
                                cursorRadius: const Radius.circular(2),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your password";
                                  }
                                  if (value.length < 8) {
                                    return "Password must be at least 8 characters";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: cs.onPrimary.withOpacity(0.75),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: cs.onPrimary.withOpacity(0.75),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hintStyle: TextStyle(
                                    color: cs.onPrimary.withOpacity(0.75),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(color: cs.secondary),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                      color: cs.secondary,
                                      width: 2,
                                    ),
                                  ),
                                  errorStyle: TextStyle(color: cs.error),
                                ),
                                style: TextStyle(color: cs.onPrimary),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Forget Password (opens popup)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => ForgetPasswordPopup(
                                  initialEmail: _emailController.text.trim(),
                                ),
                              );
                            },
                            child: Text(
                              "Forget password ?",
                              style: TextStyle(color: cs.onPrimary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Fixed bottom section
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 70,
                  ),
                  color: cs.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.secondary,
                          foregroundColor: cs.onSecondary,
                          minimumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: cs.onSecondary)
                            : const Text(
                                "Login",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account ? ",
                            style: TextStyle(color: cs.onSurface),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}
