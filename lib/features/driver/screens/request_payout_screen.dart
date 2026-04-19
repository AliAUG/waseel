import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/driver/screens/driver_payout_history_screen.dart';
import 'package:waseel/features/driver/screens/payout_success_screen.dart';
import 'package:waseel/features/driver/strings/driver_ui_strings.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class RequestPayoutScreen extends StatefulWidget {
  const RequestPayoutScreen({super.key});

  @override
  State<RequestPayoutScreen> createState() => _RequestPayoutScreenState();
}

class _RequestPayoutScreenState extends State<RequestPayoutScreen> {
  final _amountController = TextEditingController();
  static const _minWithdrawal = 75000;
  static const _processingFee = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  int _getAmount(int maxBalance) {
    final v = int.tryParse(_amountController.text) ?? 0;
    return v.clamp(0, maxBalance);
  }

  void _setAmount(int amount) {
    _amountController.text = amount.toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = DriverUiStrings(context.watch<SettingsProvider>().language);
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
        title: Column(
          children: [
            Text(
              d.reqPayoutEyebrow,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1,
              ),
            ),
            Text(
              d.requestPayoutTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<DriverProvider>(
        builder: (context, driver, _) {
          final balance = driver.totalEarnings;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.availableBalance,
                        style: TextStyle(
                          fontSize: 14,
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
                const SizedBox(height: 24),
                // Withdrawal amount
                Text(
                  d.withdrawalAmount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: ' L.L',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  d.minWithdrawalLine(
                    formatLebanesePounds(_minWithdrawal),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                // Quick amount buttons
                Row(
                  children: [
                    _AmountButton(
                      label: '150K L.L',
                      amount: 150000,
                      onTap: () => _setAmount(150000),
                    ),
                    const SizedBox(width: 12),
                    _AmountButton(
                      label: '750K L.L',
                      amount: 750000,
                      onTap: () => _setAmount(750000),
                    ),
                    const SizedBox(width: 12),
                    _AmountButton(
                      label: '1500K L.L',
                      amount: 1500000,
                      onTap: () => _setAmount(1500000),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Payout method
                Text(
                  d.payoutMethod,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryTeal, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          color: AppTheme.primaryTeal, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.wishMoney,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            Text(
                              d.wishMoneyTransferSub,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              d.instantTransfer,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle,
                          color: AppTheme.primaryTeal, size: 24),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  d.payoutInstantBlurb,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          d.payoutInfoBanner,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Withdrawal Summary
                if (_getAmount(driver.totalEarnings) >= _minWithdrawal) ...[
                  _SummaryRow(
                    label: d.withdrawalAmountSummary,
                    value: formatLebanesePounds(_getAmount(driver.totalEarnings)),
                    valueColor: Colors.grey.shade900,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: d.processingFeeSummary,
                    value: formatLebanesePounds(_processingFee),
                    valueColor: Colors.grey.shade900,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: d.youWillReceiveSummary,
                    value: formatLebanesePounds(_getAmount(driver.totalEarnings) - _processingFee),
                    valueColor: Colors.green.shade700,
                    valueBold: true,
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: d.remainingBalanceSummary,
                    value: formatLebanesePounds(
                      (driver.totalEarnings - _getAmount(driver.totalEarnings)).clamp(0, driver.totalEarnings),
                    ),
                    valueColor: Colors.grey.shade900,
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _confirmWithdrawal(context, driver, d),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(d.confirmWithdrawal),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      flow.buttonCancel,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const DriverPayoutHistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      d.viewPayoutHistory,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w600,
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

  Future<void> _confirmWithdrawal(
    BuildContext context,
    DriverProvider driver,
    DriverUiStrings d,
  ) async {
    final text = _amountController.text;
    final amount = int.tryParse(text) ?? 0;
    if (amount < _minWithdrawal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            d.minWithdrawalSnack(formatLebanesePounds(_minWithdrawal)),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    if (amount > driver.totalEarnings) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(d.exceedsBalanceSnack),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final token = context.read<AuthProvider>().token;
    final ok = await driver.requestPayout(token, amount);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            d.payoutFailed,
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    final remaining = driver.totalEarnings;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PayoutSuccessScreen(
          amount: amount,
          remainingBalance: remaining,
          transactionId: 'PAY-${DateTime.now().millisecondsSinceEpoch % 100000}',
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueBold = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool valueBold;

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
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _AmountButton extends StatelessWidget {
  const _AmountButton({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  final String label;
  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
