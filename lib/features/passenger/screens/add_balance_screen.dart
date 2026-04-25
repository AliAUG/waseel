import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/models/payment_method.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/providers/wallet_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';
import 'package:waseel/features/passenger/screens/add_payment_method_screen.dart';
import 'package:waseel/features/passenger/screens/balance_added_screen.dart';

const _presetAmounts = [50000, 100000, 200000, 500000];

class AddBalanceScreen extends StatefulWidget {
  const AddBalanceScreen({super.key});

  @override
  State<AddBalanceScreen> createState() => _AddBalanceScreenState();
}

class _AddBalanceScreenState extends State<AddBalanceScreen> {
  int? _selectedAmount;
  final _customController = TextEditingController();
  bool _useCustomAmount = false;
  bool _submitting = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  int? get _effectiveAmount {
    if (_useCustomAmount) {
      final text = _customController.text.replaceAll(',', '');
      final val = int.tryParse(text);
      return val != null && val > 0 ? val : null;
    }
    return _selectedAmount;
  }

  Future<void> _confirmTopUp(
    BuildContext context,
    WalletProvider wallet,
    int amount,
  ) async {
    final token = context.read<AuthProvider>().token;
    final isRealToken = token != null &&
        token.isNotEmpty &&
        token != 'local-session';
    final pm = wallet.selectedPaymentMethod;
    if (!isRealToken && pm == null) {
      final flow = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.selectPaymentMethodSnack)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final TopUpResult result;
      if (isRealToken) {
        result = await wallet.topUpAuthenticated(token, amount, pm);
      } else {
        result = wallet.topUp(amount);
      }
      if (!context.mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BalanceAddedScreen(result: result),
        ),
      );
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          flow.addBalanceTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<WalletProvider>(
        builder: (context, wallet, _) {
          final effectiveAmount = _effectiveAmount;
          final newBalance = effectiveAmount != null
              ? wallet.balance + effectiveAmount
              : null;
          final authToken = context.read<AuthProvider>().token;
          final isLoggedIn = authToken != null &&
              authToken.isNotEmpty &&
              authToken != 'local-session';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BalanceCard(
                  balance: wallet.balance,
                  label: flow.currentBalance,
                  showWalletIcon: true,
                ),
                const SizedBox(height: 28),
                Text(
                  flow.chooseAmount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _presetAmounts.map((amount) {
                    final isSelected =
                        !_useCustomAmount && _selectedAmount == amount;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _useCustomAmount = false;
                          _selectedAmount = amount;
                          _customController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryTeal.withValues(alpha: 0.1)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          '${amount ~/ 1000}K L.L',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppTheme.primaryTeal
                                : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  flow.orCustomAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: flow.enterAmountHint,
                    suffixText: 'L.L',
                    suffixStyle: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {
                      if (_customController.text.isNotEmpty) {
                        _useCustomAmount = true;
                        _selectedAmount = null;
                      } else {
                        _useCustomAmount = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  flow.selectPaymentMethod,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                ...wallet.paymentMethods.map((pm) {
                  final isSelected =
                      wallet.selectedPaymentMethodId == pm.id;
                  return _PaymentMethodCard(
                    paymentMethod: pm,
                    expiryLine: flow.expiresLine(pm.expiry),
                    isSelected: isSelected,
                    onTap: () => wallet.selectPaymentMethod(pm.id),
                  );
                }),
                if (wallet.paymentMethods.isEmpty && isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      flow.noSavedCardsTopUpNote,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    if (!isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(flow.signInToAddPaymentMethod),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AddPaymentMethodScreen(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 20, color: AppTheme.primaryTeal),
                      const SizedBox(width: 8),
                      Text(
                        flow.addNewPaymentMethodLong,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (effectiveAmount != null && effectiveAmount > 0) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: flow.summaryTopUpAmount,
                          value: formatLebanesePounds(effectiveAmount),
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: flow.summaryNewBalance,
                          value: formatLebanesePounds(newBalance!),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: effectiveAmount != null &&
                            effectiveAmount > 0 &&
                            !_submitting
                        ? () => _confirmTopUp(context, wallet, effectiveAmount)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(flow.confirmTopUp),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      flow.backToWallet,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.balance,
    required this.label,
    this.showWalletIcon = false,
  });

  final int balance;
  final String label;
  final bool showWalletIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showWalletIcon) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatLebanesePounds(balance),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.paymentMethod,
    required this.expiryLine,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethod paymentMethod;
  final String expiryLine;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              paymentMethod.type == 'Visa'
                  ? Icons.credit_card
                  : Icons.credit_card,
              size: 28,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paymentMethod.displayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    expiryLine,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
