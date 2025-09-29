import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImage;
  bool _loading = false;

  final RegExp _cnicRegex = RegExp(r'^\d{5}-\d{7}-\d$');

  @override
  void initState() {
    super.initState();
    _setupCnicAutoDash();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cnicCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  void _setupCnicAutoDash() {
    _cnicCtrl.addListener(() {
      final raw = _cnicCtrl.text;
      String digits = raw.replaceAll(RegExp(r'\D'), '');
      if (digits.length > 13) digits = digits.substring(0, 13);

      String formatted;
      if (digits.length <= 5) {
        formatted = digits;
      } else if (digits.length <= 12) {
        formatted = '${digits.substring(0, 5)}-${digits.substring(5)}';
      } else {
        formatted =
            '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12, 13)}';
      }
      if (formatted != raw) {
        _cnicCtrl.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() => _loading = false);

    await _showSuccessPopup(context);
    Navigator.of(context).pop(true);
  }

  Future<void> _pickFromGallery() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (img != null) setState(() => _pickedImage = img);
    } catch (_) {}
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: 45,
      backgroundColor: cs.primary,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Update Profile',
        style: TextStyle(color: cs.onPrimary, fontSize: 20),
      ),
    );
  }

  Widget _field({
    required BuildContext context,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? type,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: type,
      inputFormatters: inputFormatters,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: cs.onSurface.withOpacity(0.85)),
        hintText: hint,
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: cs.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.onSurface.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.secondary, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ImageProvider? avatarImage = _pickedImage != null
        ? FileImage(File(_pickedImage!.path))
        : null;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: cs.onPrimary,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Icon(Icons.person, color: cs.primary, size: 52)
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: cs.secondary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _pickFromGallery,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.photo_library_rounded,
                              size: 16,
                              color: cs.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _field(
                  context: context,
                  icon: Icons.person,
                  hint: 'Full Name',
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 12),
                _field(
                  context: context,
                  icon: Icons.badge,
                  hint: 'CNIC',
                  controller: _cnicCtrl,
                  type: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final val = v?.trim() ?? '';
                    if (val.isEmpty) return 'Enter CNIC';
                    if (val.length != 15 || !_cnicRegex.hasMatch(val)) {
                      return 'Invalid CNIC format (xxxxx-xxxxxxx-x)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  context: context,
                  icon: Icons.flag_outlined,
                  hint: 'Country',
                  controller: _countryCtrl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter country' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  context: context,
                  icon: Icons.map_outlined,
                  hint: 'State/Province',
                  controller: _stateCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter state/province'
                      : null,
                ),
                const SizedBox(height: 12),
                _field(
                  context: context,
                  icon: Icons.location_city,
                  hint: 'City',
                  controller: _cityCtrl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter city' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  context: context,
                  icon: Icons.location_on,
                  hint: 'Address',
                  controller: _addressCtrl,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter address' : null,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.secondary,
                      foregroundColor: cs.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? CircularProgressIndicator(color: cs.onSecondary)
                        : const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showSuccessPopup(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.circleGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: AppColors.textOnCircle,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '✅ Profile updated successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
