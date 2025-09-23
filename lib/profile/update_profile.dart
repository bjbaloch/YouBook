import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _sb = Supabase.instance.client;

  final _nameCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // ignore: unused_field
  String? _email;
  String? _avatarUrl;

  bool _loading = false;
  bool _isOnline = true;
  Timer? _netTimer;
  StreamSubscription<AuthState>? _authSub;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  final RegExp _cnicRegex = RegExp(r'^\d{5}-\d{7}-\d$');

  @override
  void initState() {
    super.initState();
    _setupCnicAutoDash();
    _loadProfile();
    _authSub = _sb.auth.onAuthStateChange.listen((_) => _loadProfile());
    _startConnectivityMonitor();
  }

  @override
  void dispose() {
    _netTimer?.cancel();
    _authSub?.cancel();
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

  void _startConnectivityMonitor() {
    _netTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final ok = await _hasInternet();
      if (ok != _isOnline) {
        if (mounted) {
          setState(() => _isOnline = ok);
          if (!ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "No internet connection. Please check your network.",
                ),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final user = _sb.auth.currentUser;
      setState(() {
        _loading = true;
        _email = user?.email;
      });

      if (user == null) {
        setState(() => _loading = false);
        return;
      }

      String? fullName,
          avatarUrl,
          cnic,
          address,
          city,
          stateProvince,
          country,
          email;

      try {
        final row = await _sb
            .from('profiles')
            .select(
              'full_name, avatar_url, cnic, address, city, state_province, country, email',
            )
            .eq('id', user.id)
            .maybeSingle();

        if (row != null) {
          fullName = (row['full_name'] as String?)?.trim();
          avatarUrl = (row['avatar_url'] as String?)?.trim();
          cnic = (row['cnic'] as String?)?.trim();
          address = (row['address'] as String?)?.trim();
          city = (row['city'] as String?)?.trim();
          stateProvince = (row['state_province'] as String?)?.trim();
          country = (row['country'] as String?)?.trim();
          email = (row['email'] as String?)?.trim();
        }
      } catch (e) {
        debugPrint('profiles fetch error: $e');
      }

      final userMeta = user.userMetadata ?? {};
      fullName ??=
          (userMeta['full_name'] as String?) ?? (userMeta['name'] as String?);
      avatarUrl ??= (userMeta['avatar_url'] as String?);

      if (!mounted) return;
      _nameCtrl.text = fullName ?? '';
      _cnicCtrl.text = cnic ?? '';
      _addressCtrl.text = address ?? '';
      _cityCtrl.text = city ?? '';
      _stateCtrl.text = stateProvince ?? '';
      _countryCtrl.text = country ?? '';
      _avatarUrl = (avatarUrl != null && avatarUrl.isNotEmpty)
          ? avatarUrl
          : null;
      _email = email ?? user.email;

      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _uploadAvatarIfNeeded(String userId) async {
    if (_pickedImage == null) return null;
    try {
      final file = File(_pickedImage!.path);
      final path =
          'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _sb.storage
          .from('avatars')
          .upload(
            path,
            file,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      return _sb.storage.from('avatars').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_isOnline) {
      _showSnack("No internet connection.");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final user = _sb.auth.currentUser;
    if (user == null) return;

    setState(() => _loading = true);
    final start = DateTime.now();
    Future<void> ensureMinDelay() async {
      final elapsed = DateTime.now().difference(start);
      if (elapsed < const Duration(seconds: 2)) {
        await Future.delayed(const Duration(seconds: 2) - elapsed);
      }
    }

    try {
      final newAvatarUrl = await _uploadAvatarIfNeeded(user.id);
      if (newAvatarUrl != null) _avatarUrl = newAvatarUrl;

      final Map<String, dynamic> upsertData = {
        'id': user.id,
        'email': user.email?.toLowerCase(),
        'full_name': _nameCtrl.text.trim(),
        'cnic': _cnicCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state_province': _stateCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'avatar_url': _avatarUrl?.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _sb.from('profiles').upsert(upsertData);

      await ensureMinDelay();
      if (!mounted) return;
      await _showSuccessPopup(context);
      Navigator.of(context).pop(true);
    } catch (e) {
      await ensureMinDelay();
      _showSnack("❌ Failed to update profile: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickFromGallery() async {
    if (!_isOnline) {
      _showSnack("No internet connection.");
      return;
    }
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
        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600),
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
        : (_avatarUrl != null && _avatarUrl!.isNotEmpty
              ? NetworkImage(_avatarUrl!)
              : null);

    return Scaffold(
      backgroundColor: cs.background,
      appBar: _appBar(context),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                ? Icon(
                                    Icons.person,
                                    color: cs.primary,
                                    size: 52,
                                  )
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter country'
                            : null,
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter city'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        context: context,
                        icon: Icons.location_on,
                        hint: 'Address',
                        controller: _addressCtrl,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter address'
                            : null,
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_loading || !_isOnline)
                              ? null
                              : _updateProfile,
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
