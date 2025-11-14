// sign_up_page.dart
import 'dart:async';
import 'dart:io'; // for SocketException & connectivity check
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/color_schema/app_colors.dart';
import 'package:final_year_project/user_selection/user_selection.dart';
import 'signup_errors.dart' as errs;

// Simple debouncer for "while typing" checks
class Debouncer {
  Debouncer(this.ms);
  final int ms;
  Timer? _timer;
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: ms), action);
  }

  void dispose() => _timer?.cancel();
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFN = FocusNode();
  final _phoneFN = FocusNode();
  final _cnicFN = FocusNode();

  final _emailDebouncer = Debouncer(600);
  final _phoneDebouncer = Debouncer(600);
  final _cnicDebouncer = Debouncer(600);

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isContinueLoading = false;

  bool _isEmailValid = true;
  bool _isPhoneValid = true;

  String? _emailServerError;
  String? _phoneServerError;
  String? _cnicServerError;

  final supabase = Supabase.instance.client;

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp passwordRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
  );
  final RegExp phoneRegex = RegExp(r'^(03|92)\d{9}$');

  String _canonicalEmail(String s) => s.trim().toLowerCase();

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _hasInternet() async {
    try {
      final res = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ----- Realtime (async) uniqueness checks -----
  Future<void> _checkEmailAvailability({
    bool showNoInternetSnack = true,
  }) async {
    final email = _canonicalEmail(_emailController.text);
    if (email.isEmpty || !emailRegex.hasMatch(email)) return;

    setState(() => _emailServerError = null);

    try {
      final result = await supabase
          .from('profiles')
          .select('id')
          .ilike('email', email)
          .maybeSingle();
      final exists = result != null;

      if (!mounted) return;
      setState(() {
        _emailServerError = exists
            ? errs.SignUpErrorUtils.emailDuplicateMsg
            : null;
      });
    } on SocketException {
      if (showNoInternetSnack) _showSnack(errs.SignUpErrorUtils.noInternetMsg);
    } catch (e) {
      if (showNoInternetSnack &&
          errs.SignUpErrorUtils.looksLikeNetworkIssue(e)) {
        _showSnack(errs.SignUpErrorUtils.noInternetMsg);
      }
    }
  }

  Future<void> _checkPhoneAvailability({
    bool showNoInternetSnack = true,
  }) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !phoneRegex.hasMatch(phone)) return;

    setState(() => _phoneServerError = null);

    try {
      final result = await supabase
          .from('profiles')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
      final exists = result != null;

      if (!mounted) return;
      setState(() {
        _phoneServerError = exists
            ? errs.SignUpErrorUtils.phoneDuplicateMsg
            : null;
      });
    } on SocketException {
      if (showNoInternetSnack) _showSnack(errs.SignUpErrorUtils.noInternetMsg);
    } catch (e) {
      if (showNoInternetSnack &&
          errs.SignUpErrorUtils.looksLikeNetworkIssue(e)) {
        _showSnack(errs.SignUpErrorUtils.noInternetMsg);
      }
    }
  }

  Future<void> _checkCnicAvailability({bool showNoInternetSnack = true}) async {
    final cnic = _cnicController.text.trim();
    if (cnic.isEmpty || cnic.length != 15) return;

    setState(() => _cnicServerError = null);

    try {
      final result = await supabase
          .from('profiles')
          .select('id')
          .eq('cnic', cnic)
          .maybeSingle();
      final exists = result != null;

      if (!mounted) return;
      setState(() {
        _cnicServerError = exists
            ? errs.SignUpErrorUtils.cnicDuplicateMsg
            : null;
      });
    } on SocketException {
      if (showNoInternetSnack) _showSnack(errs.SignUpErrorUtils.noInternetMsg);
    } catch (e) {
      if (showNoInternetSnack &&
          errs.SignUpErrorUtils.looksLikeNetworkIssue(e)) {
        _showSnack(errs.SignUpErrorUtils.noInternetMsg);
      }
    }
  }

  Future<bool> _checkFieldAvailability() async {
    final email = _canonicalEmail(_emailController.text);
    final phone = _phoneController.text.trim();
    final cnic = _cnicController.text.trim();

    setState(() {
      _emailServerError = null;
      _phoneServerError = null;
      _cnicServerError = null;
    });

    try {
      final List<Future<dynamic>> futures = <Future<dynamic>>[
        if (emailRegex.hasMatch(email) && email.isNotEmpty)
          supabase
              .from('profiles')
              .select('id')
              .ilike('email', email)
              .maybeSingle()
        else
          Future<dynamic>.value(null),
        if (phoneRegex.hasMatch(phone) && phone.isNotEmpty)
          supabase
              .from('profiles')
              .select('id')
              .eq('phone', phone)
              .maybeSingle()
        else
          Future<dynamic>.value(null),
        if (cnic.length == 15 && cnic.isNotEmpty)
          supabase.from('profiles').select('id').eq('cnic', cnic).maybeSingle()
        else
          Future<dynamic>.value(null),
      ];

      final results = await Future.wait<dynamic>(futures);
      final emailExists = results[0] != null;
      final phoneExists = results[1] != null;
      final cnicExists = results[2] != null;

      if (mounted) {
        setState(() {
          _emailServerError = emailExists
              ? errs.SignUpErrorUtils.emailDuplicateMsg
              : null;
          _phoneServerError = phoneExists
              ? errs.SignUpErrorUtils.phoneDuplicateMsg
              : null;
          _cnicServerError = cnicExists
              ? errs.SignUpErrorUtils.cnicDuplicateMsg
              : null;
        });
      }
      return !(emailExists || phoneExists || cnicExists);
    } on SocketException {
      _showSnack(errs.SignUpErrorUtils.noInternetMsg);
      return false;
    } catch (e) {
      if (errs.SignUpErrorUtils.looksLikeNetworkIssue(e)) {
        _showSnack(errs.SignUpErrorUtils.noInternetMsg);
      } else {
        _showSnack("Something went wrong while checking availability.");
      }
      return false;
    }
  }

  // ---------------- SIGN UP -------------------
  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (!await _hasInternet()) {
      _showSnack("No internet connection.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ok = await _checkFieldAvailability();
      if (!ok) return;

      final email = _canonicalEmail(_emailController.text);
      final authResp = await supabase.auth.signUp(
        email: email,
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'cnic': _cnicController.text.trim(),
        },
        emailRedirectTo: 'youbook://auth-callback',
      );

      final userId = authResp.user?.id;
      if (userId != null) {
        await supabase.from('profiles').upsert({
          'id': userId,
          'email': email,
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'cnic': _cnicController.text.trim(),
          'role': null,
          'avatar_url': null,
          'address': null,
          'city': null,
          'state_province': null,
          'country': null,
          'updated_at': DateTime.now().toIso8601String(),
        }); // fixed: include null defaults, removed .select()
      }

      final session = authResp.session;
      if (session == null) {
        _showSnack("We’ve sent a confirmation link to your email.");
        return;
      }

      if (mounted) {
        _showSnack("✅ Account created successfully!");
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      }
    } catch (e) {
      _showSnack("❌ Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- CONTINUE AFTER CONFIRM ----------------
  Future<void> _continueAfterConfirmation() async {
    final email = _canonicalEmail(_emailController.text);
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showSnack("Please enter your email and password.");
      return;
    }
    if (!await _hasInternet()) {
      _showSnack("No internet connection.");
      return;
    }

    setState(() => _isContinueLoading = true);
    try {
      final resp = await supabase.auth.signInWithPassword(
        email: email,
        password: pass,
      );

      if (resp.session != null) {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      } else {
        _showSnack("Could not continue. Please try again.");
      }
    } catch (e) {
      _showSnack("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isContinueLoading = false);
    }
  }

  // ---------- UI helpers ----------
  void _formatCnic(String value) {
    String numbers = value.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    if (numbers.length > 5) {
      formatted = numbers.substring(0, 5) + '-';
      if (numbers.length > 12) {
        formatted += numbers.substring(5, 12) + '-' + numbers.substring(12);
      } else if (numbers.length > 5) {
        formatted += numbers.substring(5);
      }
    } else {
      formatted = numbers;
    }
    if (formatted != value) {
      _cnicController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _emailController.addListener(() {
      final valid = emailRegex.hasMatch(_emailController.text);
      if (mounted) {
        setState(() {
          _isEmailValid = valid;
          if (_emailServerError != null) _emailServerError = null;
        });
      }
      if (valid) {
        _emailDebouncer.run(
          () => _checkEmailAvailability(showNoInternetSnack: false),
        );
      }
    });

    _phoneController.addListener(() {
      final valid = phoneRegex.hasMatch(_phoneController.text);
      if (mounted) {
        setState(() {
          _isPhoneValid = valid;
          if (_phoneServerError != null) _phoneServerError = null;
        });
      }
      if (valid) {
        _phoneDebouncer.run(
          () => _checkPhoneAvailability(showNoInternetSnack: false),
        );
      }
    });

    _cnicController.addListener(() {
      _formatCnic(_cnicController.text);
      if (_cnicServerError != null && mounted) {
        setState(() {
          _cnicServerError = null;
        });
      }
      if (_cnicController.text.trim().length == 15) {
        _cnicDebouncer.run(
          () => _checkCnicAvailability(showNoInternetSnack: false),
        );
      }
    });

    _emailFN.addListener(() {
      if (!_emailFN.hasFocus) _checkEmailAvailability();
    });
    _phoneFN.addListener(() {
      if (!_phoneFN.hasFocus) _checkPhoneAvailability();
    });
    _cnicFN.addListener(() {
      if (!_cnicFN.hasFocus) _checkCnicAvailability();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFN.dispose();
    _phoneFN.dispose();
    _cnicFN.dispose();
    _emailDebouncer.dispose();
    _phoneDebouncer.dispose();
    _cnicDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              // Green Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 20,
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Create an account",
                      style: TextStyle(fontSize: 15, color: cs.onPrimary),
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      icon: Icons.person,
                      hint: "Full Name",
                      controller: _nameController,
                      validator: (val) => (val == null || val.isEmpty)
                          ? "Enter your name"
                          : null,
                      borderColor: cs.secondary,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      icon: Icons.email,
                      hint: "Email",
                      controller: _emailController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter email";
                        if (!emailRegex.hasMatch(val))
                          return "Enter valid email";
                        return null;
                      },
                      borderColor: (_emailServerError != null || !_isEmailValid)
                          ? cs.error
                          : cs.secondary,
                      serverError: _emailServerError,
                      focusNode: _emailFN,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      icon: Icons.phone,
                      hint: "Phone Number",
                      controller: _phoneController,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return "Enter phone number";
                        if (!phoneRegex.hasMatch(val))
                          return "Enter valid phone number";
                        return null;
                      },
                      borderColor: (_phoneServerError != null || !_isPhoneValid)
                          ? cs.error
                          : cs.secondary,
                      serverError: _phoneServerError,
                      focusNode: _phoneFN,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      icon: Icons.badge,
                      hint: "CNIC",
                      controller: _cnicController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter CNIC";
                        if (val.length != 15) return "Invalid CNIC format";
                        return null;
                      },
                      borderColor: (_cnicServerError != null)
                          ? cs.error
                          : cs.secondary,
                      serverError: _cnicServerError,
                      focusNode: _cnicFN,
                    ),
                    const SizedBox(height: 10),

                    _buildPasswordField("Password", true, _passwordController, (
                      val,
                    ) {
                      if (val == null || val.isEmpty) return "Enter password";
                      if (!passwordRegex.hasMatch(val)) {
                        return "Must have 8+ chars, upper, lower, number, special";
                      }
                      return null;
                    }),
                    const SizedBox(height: 10),

                    _buildPasswordField(
                      "Confirm Password",
                      false,
                      _confirmPasswordController,
                      (val) {
                        if (val != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "By signing up you are agree to our Terms Condition & Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onBackground.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 70),

              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: cs.onSecondary)
                      : Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16, color: cs.onSecondary),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_isContinueLoading || _isLoading)
                      ? null
                      : _continueAfterConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isContinueLoading
                      ? CircularProgressIndicator(
                          color: cs.onSecondary,
                          strokeWidth: 2,
                        )
                      : Text(
                          "Confirmed, continue",
                          style: TextStyle(fontSize: 16, color: cs.onSecondary),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an Account ? "),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    Color borderColor = AppColors.accentOrange,
    String? serverError,
    FocusNode? focusNode,
  }) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      validator: validator,
      cursorColor: cs.secondary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      style: TextStyle(color: cs.onPrimary),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: cs.onPrimary.withOpacity(0.85)),

        // ✅ Floating label behaves like previous code
        labelText: hint,
        labelStyle: TextStyle(color: AppColors.textWhite),
        floatingLabelStyle: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),

        filled: true,
        fillColor: AppColors.transparent,
        errorText: serverError,
        errorMaxLines: 2,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: cs.secondary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
      keyboardType: (hint == "Phone Number" || hint == "CNIC")
          ? TextInputType.number
          : TextInputType.text,
      inputFormatters: (hint == "Phone Number" || hint == "CNIC")
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
    );
  }

  Widget _buildPasswordField(
    String hint,
    bool isPassword,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
      validator: validator,
      cursorColor: cs.secondary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      style: TextStyle(color: cs.onPrimary),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock, color: cs.onPrimary.withOpacity(0.85)),
        suffixIcon: IconButton(
          icon: Icon(
            isPassword
                ? (_obscurePassword ? Icons.visibility : Icons.visibility_off)
                : (_obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
            color: cs.onPrimary.withOpacity(0.75),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),

        // ✅ Floating label style (same behavior)
        labelText: hint,
        labelStyle: TextStyle(color: AppColors.textWhite),
        floatingLabelStyle: TextStyle(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w600,
        ),

        filled: true,
        fillColor: Colors.transparent,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: cs.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: cs.secondary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
