/// Login UI - User interface for login feature
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/core/theme/app_colors.dart';
import 'package:final_year_project/features/login/logic/login_logic.dart';
import 'package:final_year_project/Login/forget_password_popup.dart';
import 'package:final_year_project/features/signup/ui/signup_page.dart';
import 'package:final_year_project/features/manager_home/ui/manager_home.dart';

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
  DateTime? _lastBackPressTime;
  
  late final LoginLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = LoginLogic(context: context);
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
      return false;
    }
    SystemNavigator.pop();
    return false;
  }

  // Handle login process
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // Smooth loading

    final result = await _logic.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Login successful!")),
      );

      if (result.role == 'manager') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ManagerHome()),
          (route) => false,
        );
      } else {
        // Navigate to customer home
        // Navigator.of(context).pushAndRemoveUntil(
        //   MaterialPageRoute(builder: (_) => const CustomerHome()),
        //   (route) => false,
        // );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? "Login failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: cs.background,
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 180),
              child: Column(
                children: [
                  // Green Header
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
                        // YOUBOOK text
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

                        // Form
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
                                validator: _logic.validateEmail,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  labelStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: cs.onPrimary.withOpacity(0.75),
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
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
                                validator: _logic.validatePassword,
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: const TextStyle(
                                    color: AppColors.textWhite,
                                  ),
                                  floatingLabelStyle: const TextStyle(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
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

                        // Forget Password
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

            // Fixed bottom section
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
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
                                style: TextStyle(fontSize: 16),
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

