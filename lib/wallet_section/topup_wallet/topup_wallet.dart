import 'package:flutter/material.dart';
import 'package:final_year_project/color_schema/app_colors.dart';

class TopupAccountsPage extends StatefulWidget {
  const TopupAccountsPage({super.key});

  @override
  State<TopupAccountsPage> createState() => _TopupAccountsPageState();
}

class _TopupAccountsPageState extends State<TopupAccountsPage> {
  String _selectedPaymentMethod = '';
  final TextEditingController _amountController = TextEditingController();
  double _topupAmount = 0.0;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateTopupAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateTopupAmount);
    _amountController.dispose();
    super.dispose();
  }

  void _updateTopupAmount() {
    setState(() {
      _topupAmount = double.tryParse(_amountController.text) ?? 0.0;
      if (_amountController.text.isNotEmpty) {
        _amountError = null;
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePaymentTap(String method) {
    FocusScope.of(context).unfocus();

    // Clear any temporary selection on each tap
    setState(() {
      _selectedPaymentMethod = '';
    });

    if (_amountController.text.isEmpty) {
      setState(() {
        _amountError = "The amount is required to proceed";
      });
      return;
    }

    if (_topupAmount < 40 || _topupAmount > 10000) {
      _showSnackBar("The amount must be between 40 and 10000.");
      return;
    }

    // Only mark as selected if amount is valid
    setState(() {
      _selectedPaymentMethod = method;
      _amountError = null;
    });

    debugPrint('Navigating to $method payment page...');
    // TODO: Add navigation logic later
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: AppColors.lightSeaGreen,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textWhite,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Topup Accounts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  Icon(Icons.payment, size: 42, color: AppColors.accentOrange),
                  const SizedBox(height: 8),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'Topup your Youbook Wallet with your payment methods.',
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onBackground.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 10),

              // Amount input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.textBlack : AppColors.dialogBg,
                  labelText: 'Enter amount',
                  labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                  prefixText: 'Rs. ',
                  errorText: _amountError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: AppColors.accentOrange,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: cs.onSurface.withOpacity(0.3),
                      width: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onBackground,
                ),
              ),
              const SizedBox(height: 16),

              _buildPaymentMethodTile(
                context,
                'Easypaisa',
                'assets/topup_accounts/easypaisa.png',
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodTile(
                context,
                'JazzCash',
                'assets/topup_accounts/jazzcash_logo.png',
              ),
              const SizedBox(height: 16),
              _buildPaymentMethodTile(
                context,
                'Debit / Visa Card',
                'assets/topup_accounts/visa_card.png',
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context,
    String method,
    String logoAssetPath,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => _handlePaymentTap(method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D1F) : AppColors.dialogBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.accentOrange
                : cs.onSurface.withOpacity(0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.accentOrange.withOpacity(0.25),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            BoxShadow(
              color: isDark
                  ? AppColors.textBlack.withOpacity(0.1)
                  : AppColors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                logoAssetPath,
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.circleGreen : cs.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.circleGreen,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
