import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/providers/wallet_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

/// Full-screen receipt after a successful wallet top-up.
class TopUpReceiptScreen extends StatelessWidget {
  const TopUpReceiptScreen({super.key, required this.result});

  final TopUpResult result;

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 22),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          flow.receiptTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Waseel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                flow.receiptWalletTopUp,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.grey.shade300, height: 1),
              ),
              _ReceiptRow(
                label: flow.receiptAmount,
                value: formatLebanesePounds(result.amount),
                emphasize: true,
              ),
              const SizedBox(height: 16),
              _ReceiptRow(
                label: flow.receiptNewBalanceRow,
                value: formatLebanesePounds(result.newBalance),
              ),
              const SizedBox(height: 16),
              _ReceiptRow(
                label: flow.transactionIdLabel,
                value: result.transactionId,
              ),
              const SizedBox(height: 16),
              _ReceiptRow(
                label: flow.receiptPaymentMethodRow,
                value: result.paymentMethod.displayName,
              ),
              const SizedBox(height: 16),
              _ReceiptRow(
                label: flow.receiptDateTimeRow,
                value: flow.formatTopUpReceiptDateTime(result.dateTime),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.grey.shade300, height: 1),
              ),
              Text(
                flow.receiptThankYou,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: emphasize ? 17 : 14,
              fontWeight: emphasize ? FontWeight.bold : FontWeight.w600,
              color: emphasize ? AppTheme.primaryTeal : Colors.grey.shade900,
            ),
          ),
        ),
      ],
    );
  }
}
