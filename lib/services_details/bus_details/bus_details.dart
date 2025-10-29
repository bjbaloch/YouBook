import 'package:final_year_project/services_details/service_confirmation/service_confirmation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class AddBusDetailsScreen extends StatefulWidget {
  const AddBusDetailsScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(builder: (_) => const AddBusDetailsScreen());
  }

  @override
  State<AddBusDetailsScreen> createState() => _AddBusDetailsScreenState();
}

class _AddBusDetailsScreenState extends State<AddBusDetailsScreen> {
  bool _isAgreedToTerms = false;
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _applicationController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _arrivalController = TextEditingController();
  String? _selectedBusType;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updateApplicationCharges);
  }

  void _updateApplicationCharges() {
    final text = _priceController.text.trim();
    if (text.isEmpty) {
      _applicationController.text = '';
      return;
    }
    final price = double.tryParse(text);
    if (price != null) {
      final charges = price * 0.03;
      _applicationController.text = charges.toStringAsFixed(2);
    } else {
      _applicationController.text = '';
    }
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 10));

    // Smooth Flutter transitions (default dialogs)
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return;

    // Slight pause for smoother feel
    await Future.delayed(const Duration(milliseconds: 150));

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    controller.text = '${dateTime.toLocal()}'.split('.')[0];
  }

  @override
  void dispose() {
    _priceController.dispose();
    _applicationController.dispose();
    _departureController.dispose();
    _arrivalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            elevation: 0,
            title: const Text(
              'Add Bus Details',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: true,
            backgroundColor: cs.primary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BusInformationSection(
                  selectedBusType: _selectedBusType,
                  onBusTypeChanged: (value) {
                    setState(() {
                      _selectedBusType = value;
                    });
                  },
                ),
                const _DriverInformationSection(),
                const _ProprietorInformationSection(),
                const _RouteInformationSection(),
                const _OfficeTerminalSection(),
                _ScheduleDetailsSection(
                  departureController: _departureController,
                  arrivalController: _arrivalController,
                  onPickDateTime: _pickDateTime,
                ),
                _SeatLayoutSection(
                  priceController: _priceController,
                  applicationController: _applicationController,
                ),
                const _OperationalControlsSection(),
                _DisclaimerSection(
                  isAgreed: _isAgreedToTerms,
                  onChanged: (newValue) {
                    setState(() {
                      _isAgreedToTerms = newValue ?? false;
                    });
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // ✅ Open the popup dialog directly
              showServiceConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Save Bus Details',
              style: TextStyle(fontSize: 16, color: AppColors.textWhite),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Common Widgets ----------

class SectionHeader extends StatelessWidget {
  final String titleEn;
  final String titleUr;
  final bool isRequired;

  const SectionHeader({
    super.key,
    required this.titleEn,
    required this.titleUr,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
                children: [
                  TextSpan(text: '$titleEn ($titleUr)'),
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInputField extends StatefulWidget {
  final String labelEn;
  final String labelUr;
  final bool isRequired;
  final Icon? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final int maxLines;

  const CustomInputField({
    super.key,
    required this.labelEn,
    required this.labelUr,
    this.isRequired = false,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: TextFormField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.maxLines,
          keyboardType: widget.labelEn == 'Price Per Seat'
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: widget.labelEn == 'Price Per Seat'
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
              : [],
          onChanged: widget.onChanged,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          decoration: InputDecoration(
            labelText: '${widget.labelEn} (${widget.labelUr})',
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
            ),

            filled: true,
            fillColor: cs.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: widget.suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.onSurface.withOpacity(0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.accentOrange,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Section Container ----------
Widget _sectionContainer({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(12.0),
    margin: const EdgeInsets.only(bottom: 12.0),
    decoration: BoxDecoration(
      color: AppColors.lightSeaGreen.withOpacity(0.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

// ---------- All Updated Sections ----------

class _BusInformationSection extends StatelessWidget {
  final String? selectedBusType;
  final ValueChanged<String?> onBusTypeChanged;

  const _BusInformationSection({
    required this.selectedBusType,
    required this.onBusTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Bus Information',
          titleUr: 'بس معلومات',
          isRequired: true,
        ),
        const CustomInputField(labelEn: 'Bus Name', labelUr: 'بس نام'),
        const CustomInputField(labelEn: 'Bus Number', labelUr: 'بس نمبر'),
        const CustomInputField(labelEn: 'Bus Color', labelUr: 'بس رنگ'),
        const SizedBox(height: 6), // ✅ equal spacing
      ],
    );
  }
}

class _DriverInformationSection extends StatelessWidget {
  const _DriverInformationSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(
          titleEn: 'Driver Information',
          titleUr: 'ڈرائیور معلوماتِ ',
          isRequired: true,
        ),
        CustomInputField(labelEn: 'Driver Name', labelUr: 'ڈرائیور نام'),
        CustomInputField(
          labelEn: 'Driving Experience',
          labelUr: 'ڈرائیونگ تجربہ',
        ),
        CustomInputField(labelEn: 'Phone Number', labelUr: 'فون نمبر'),
        CustomInputField(labelEn: 'CNIC', labelUr: 'قومی شناختی کارڈ نمبر'),
      ],
    );
  }
}

// (The rest of your sections remain unchanged)

class _ProprietorInformationSection extends StatelessWidget {
  const _ProprietorInformationSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(
          titleEn: 'Proprietor Information',
          titleUr: 'مالک کی معلومات',
          isRequired: true,
        ),
        CustomInputField(labelEn: 'Proprietor', labelUr: 'مالک'),
        CustomInputField(labelEn: 'General Manager', labelUr: 'جنرل منیجر'),
        CustomInputField(labelEn: 'Manager', labelUr: 'منیجر'),
        CustomInputField(labelEn: 'Secretary', labelUr: 'سیکرٹری'),
      ],
    );
  }
}

class _RouteInformationSection extends StatelessWidget {
  const _RouteInformationSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(
          titleEn: 'Route Information',
          titleUr: 'معلوماتِ راستہ',
          isRequired: true,
        ),
        CustomInputField(labelEn: 'From', labelUr: 'سے'),
        CustomInputField(labelEn: 'To', labelUr: 'تک'),
      ],
    );
  }
}

class _OfficeTerminalSection extends StatelessWidget {
  const _OfficeTerminalSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(
          titleEn: 'Office / Terminal Information',
          titleUr: 'دفتر / ٹرمینل کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Boarding Office/Terminal',
          labelUr: 'سوار ہونے کا دفتر/اڈا',
        ),
        CustomInputField(
          labelEn: 'Arrival Office/Terminal',
          labelUr: 'منزل پر اترنے کا دفتر/اڈا',
        ),
      ],
    );
  }
}

class _ScheduleDetailsSection extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final Future<void> Function(TextEditingController) onPickDateTime;

  const _ScheduleDetailsSection({
    required this.departureController,
    required this.arrivalController,
    required this.onPickDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Schedule Details',
          titleUr: 'شیڈول تفصیلات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Departure Date & Time',
          labelUr: 'روانگی کی تاریخ اور وقت',
          controller: departureController,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
          onTap: () => onPickDateTime(departureController),
        ),
        CustomInputField(
          labelEn: 'Arrival Date & Time',
          labelUr: 'آمد کی تاریخ اور وقت',
          controller: arrivalController,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
          onTap: () => onPickDateTime(arrivalController),
        ),
      ],
    );
  }
}

class _SeatLayoutSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController applicationController;

  const _SeatLayoutSection({
    required this.priceController,
    required this.applicationController,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Seat & Pricing Details',
          titleUr: 'نشست اور قیمت کی تفصیلات',
          isRequired: true,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Placeholder()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Seat Layout (نشست کا خاکہ)',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
          ),
        ),
        CustomInputField(
          labelEn: 'Price Per Seat',
          labelUr: 'فی نشست قیمت',
          controller: priceController,
        ),
        CustomInputField(
          labelEn: 'Application Charges',
          labelUr: 'ایپلیکیشن چارجز',
          controller: applicationController,
          readOnly: true,
        ),
      ],
    );
  }
}

class _OperationalControlsSection extends StatefulWidget {
  const _OperationalControlsSection();

  @override
  State<_OperationalControlsSection> createState() =>
      _OperationalControlsSectionState();
}

class _OperationalControlsSectionState
    extends State<_OperationalControlsSection> {
  bool _isExpanded = false;

  final TextEditingController _instructionsController = TextEditingController(
    text: '''
روانگی سے 15 منٹ پہلے پہنچ جائیں۔
--------------------------------------------------------------------
سواری اپنے سامان کی خود حفاظت کرے۔
--------------------------------------------------------------------
ایک ٹکٹ پر 10 کلو سامان فری لے جاسکتے ہیں۔
--------------------------------------------------------------------
گاڑی میں سفر کرتے وقت ڈرائیور کو تیز چلانے پر مجبور نہ کریں۔
--------------------------------------------------------------------
سیٹ کینسل کروانے کی صورت میں روانگی سے 1 گھنٹہ قبل رجوع کرے ٪50 کٹوتی ہوگی۔
--------------------------------------------------------------------
اتفاقیہ حادثے کی صورت میں کسی بھی جان ومال کے نقصان کی صورت میں بکنگ کمپنی آفس زمہ دار نہیں ہوگی۔
--------------------------------------------------------------------
بیگ کے اندر نقدی اور زیورات رکھنا منع ہے گُم ہونے کی صورت میں کمپنی زمہ دار نہ ہوگی۔
--------------------------------------------------------------------
وقت پر نہ پہنچنے پر ٹکٹ ضائع ہو جائے گا۔
--------------------------------------------------------------------
غیر قانونی سامان کا مسافر خود زمہ دار ہوگا۔
--------------------------------------------------------------------
وقت کی پابندی اور نماز قائم کرے۔
--------------------------------------------------------------------
غیر قانونی اشیاء کی بکنگ نہیں کی جائے گی۔
--------------------------------------------------------------------
ڈرائیور کے ساتھ کسی قسم کے لین دین کی سواری خود زمہ دار ہو گی، کمپنی زمہ دار نہ ہوگی۔ ''',
  );

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Operational Controls',
          titleUr: 'عملی کنٹرولز',
          isRequired: true,
        ),

        // 🔽 Dropdown-style expandable area
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Instructions for Passengers (ہدایات براۓ مسافر)',
                  style: TextStyle(fontSize: 14),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),

        // ✅ Editable expanded section
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              controller: _instructionsController,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.25),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.accentOrange,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
      ],
    );
  }
}

class _DisclaimerSection extends StatelessWidget {
  final bool isAgreed;
  final ValueChanged<bool?> onChanged;

  const _DisclaimerSection({required this.isAgreed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: isAgreed,
            onChanged: onChanged,
            activeColor: AppColors.accentOrange,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              "I am sure that I provided the right details of Bus following the Terms & Conditions of YouBook, incase of wrong information i am responsible.",
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
