/// Signup UI - User interface for signup feature
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/core/theme/app_colors.dart';
import 'package:final_year_project/features/signup/logic/signup_logic.dart';
import 'package:final_year_project/shared/utils/debouncer.dart';
import 'package:final_year_project/user_selection/user_selection.dart';

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

  late final SignupLogic _logic;

  @override
  void initState() {
    super.initState();
    _logic = SignupLogic(context: context);

    _emailController.addListener(() {
      final valid = SignupLogic.emailRegex.hasMatch(_emailController.text);
      if (mounted) {
        setState(() {
          _isEmailValid = valid;
          if (_emailServerError != null) _emailServerError = null;
        });
      }
      if (valid) {
        _emailDebouncer.run(
          () async {
            final error = await _logic.checkEmailAvailability(
              _emailController.text,
              showError: false,
            );
            if (mounted && error != null) {
              setState(() => _emailServerError = error);
            }
          },
        );
      }
    });

    _phoneController.addListener(() {
      final valid = SignupLogic.phoneRegex.hasMatch(_phoneController.text);
      if (mounted) {
        setState(() {
          _isPhoneValid = valid;
          if (_phoneServerError != null) _phoneServerError = null;
        });
      }
      if (valid) {
        _phoneDebouncer.run(
          () async {
            final error = await _logic.checkPhoneAvailability(
              _phoneController.text,
              showError: false,
            );
            if (mounted && error != null) {
              setState(() => _phoneServerError = error);
            }
          },
        );
      }
    });

    _cnicController.addListener(() {
      final formatted = _logic.formatCnic(_cnicController.text);
      if (formatted != _cnicController.text) {
        _cnicController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      if (_cnicServerError != null && mounted) {
        setState(() => _cnicServerError = null);
      }
      if (_cnicController.text.trim().length == 15) {
        _cnicDebouncer.run(
          () async {
            final error = await _logic.checkCnicAvailability(
              _cnicController.text,
              showError: false,
            );
            if (mounted && error != null) {
              setState(() => _cnicServerError = error);
            }
          },
        );
      }
    });

    _emailFN.addListener(() {
      if (!_emailFN.hasFocus) {
        _logic.checkEmailAvailability(_emailController.text);
      }
    });
    _phoneFN.addListener(() {
      if (!_phoneFN.hasFocus) {
        _logic.checkPhoneAvailability(_phoneController.text);
      }
    });
    _cnicFN.addListener(() {
      if (!_cnicFN.hasFocus) {
        _logic.checkCnicAvailability(_cnicController.text);
      }
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

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _logic.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      cnic: _cnicController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      if (result.emailConfirmationRequired) {
        _showSnack(result.message ?? "We've sent a confirmation link to your email.");
        return;
      }
      _showSnack("✅ Account created successfully!");
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      }
    } else {
      _showSnack(result.message ?? "❌ Error occurred");
    }
  }

  Future<void> _continueAfterConfirmation() async {
    setState(() => _isContinueLoading = true);

    final result = await _logic.continueAfterConfirmation(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isContinueLoading = false);

    if (result.success) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
        );
      }
    } else {
      _showSnack(result.message ?? "Could not continue. Please try again.");
    }
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
                      validator: _logic.validateEmail,
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
                      validator: _logic.validatePhone,
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
                      validator: _logic.validateCnic,
                      borderColor: (_cnicServerError != null)
                          ? cs.error
                          : cs.secondary,
                      serverError: _cnicServerError,
                      focusNode: _cnicFN,
                    ),
                    const SizedBox(height: 10),

                    _buildPasswordField("Password", true, _passwordController, (
                      val,
                    ) => _logic.validatePassword(val)),
                    const SizedBox(height: 10),

                    _buildPasswordField(
                      "Confirm Password",
                      false,
                      _confirmPasswordController,
                      (val) => _logic.validateConfirmPassword(val, _passwordController.text),
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

