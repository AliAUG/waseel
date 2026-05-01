import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/providers/wallet_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

const _cardTypes = ['Visa', 'Mastercard', 'Other'];

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  String _cardType = 'Visa';
  final _lastFourController = TextEditingController();
  int _expiryMonth = DateTime.now().month;
  late int _expiryYear;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final y = DateTime.now().year;
    _expiryYear = y;
  }

  @override
  void dispose() {
    _lastFourController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final token = context.read<AuthProvider>().token;
    if (token == null ||
        token.isEmpty ||
        token == 'local-session') {
      final flow = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.signInToAddPaymentMethod)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await context.read<WalletProvider>().addCardPaymentMethod(
            token,
            cardType: _cardType,
            lastFourDigits: _lastFourController.text.trim(),
            expiryMonth: _expiryMonth,
            expiryYear: _expiryYear,
          );
      if (!mounted) return;
      final flow = PassengerFlowStrings(
        context.read<SettingsProvider>().language,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.cardSavedSnack)),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
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
    final years = List.generate(
      16,
      (i) => DateTime.now().year + i,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          flow.addCardTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                flow.cardTypeLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _cardType,
                decoration: _fieldDecoration(),
                items: _cardTypes
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _cardType = v);
                },
              ),
              const SizedBox(height: 20),
              Text(
                flow.lastFourDigitsLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastFourController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _fieldDecoration().copyWith(
                  counterText: '',
                  hintText: '4242',
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.length != 4) return flow.enterExactlyFourDigits;
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                flow.expiryLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _expiryMonth,
                      decoration: _fieldDecoration(),
                      items: List.generate(
                        12,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('${i + 1}'.padLeft(2, '0')),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) setState(() => _expiryMonth = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _expiryYear,
                      decoration: _fieldDecoration(),
                      items: years
                          .map(
                            (y) => DropdownMenuItem(
                              value: y,
                              child: Text('$y'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _expiryYear = v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                flow.cardDisclaimer,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                      : Text(flow.saveCard),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
