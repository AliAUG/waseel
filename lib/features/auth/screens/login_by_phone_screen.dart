import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/models/user_role.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/auth/screens/auth_sign_in_screen.dart';
import 'package:waseel/features/auth/screens/create_account_driver_screen.dart';
import 'package:waseel/features/auth/screens/create_account_passenger_screen.dart';
import 'package:waseel/features/auth/screens/otp_verify_screen.dart';
import 'package:waseel/features/passenger/screens/change_password_screen.dart';

class _CountryDial {
  const _CountryDial({required this.code, required this.label});
  final String code;
  final String label;
}

/// Common dial codes for the region (extend as needed).
const List<_CountryDial> _kCountryDials = [
  _CountryDial(code: '+961', label: 'Lebanon'),
  _CountryDial(code: '+962', label: 'Jordan'),
  _CountryDial(code: '+970', label: 'Palestine'),
  _CountryDial(code: '+972', label: 'Israel'),
  _CountryDial(code: '+963', label: 'Syria'),
  _CountryDial(code: '+964', label: 'Iraq'),
  _CountryDial(code: '+965', label: 'Kuwait'),
  _CountryDial(code: '+966', label: 'Saudi Arabia'),
  _CountryDial(code: '+971', label: 'United Arab Emirates'),
  _CountryDial(code: '+20', label: 'Egypt'),
  _CountryDial(code: '+90', label: 'Turkey'),
  _CountryDial(code: '+33', label: 'France'),
  _CountryDial(code: '+44', label: 'United Kingdom'),
  _CountryDial(code: '+1', label: 'United States / Canada'),
];

class LoginByPhoneScreen extends StatefulWidget {
  const LoginByPhoneScreen({
    super.key,
    this.forDriver = false,
  });

  final bool forDriver;

  @override
  State<LoginByPhoneScreen> createState() => _LoginByPhoneScreenState();
}

class _LoginByPhoneScreenState extends State<LoginByPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _countryCode = '+961';
  bool _isSendingCode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<TextInputFormatter> get _phoneInputFormatters {
    if (_countryCode == '+961') {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
        TextInputFormatter.withFunction((oldValue, newText) {
          if (newText.text.isEmpty) return newText;
          final digits = newText.text.replaceAll(RegExp(r'\D'), '');
          if (digits.length <= 2) {
            return TextEditingValue(text: digits);
          }
          if (digits.length <= 5) {
            final t =
                '${digits.substring(0, 2)} ${digits.substring(2)}';
            return TextEditingValue(
              text: t,
              selection: TextSelection.collapsed(offset: t.length),
            );
          }
          final t =
              '${digits.substring(0, 2)} ${digits.substring(2, 5)} ${digits.substring(5)}';
          return TextEditingValue(
            text: t,
            selection: TextSelection.collapsed(offset: t.length),
          );
        }),
      ];
    }
    return [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(15),
    ];
  }

  String? _validatePhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (_countryCode == '+961') {
      return digits.length < 8 ? 'Enter a valid phone number' : null;
    }
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  void _showCountryDialPicker() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Text(
                  'Country code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              for (final c in _kCountryDials)
                ListTile(
                  title: Text(c.label),
                  trailing: Text(
                    c.code,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  selected: c.code == _countryCode,
                  onTap: () {
                    setState(() {
                      if (c.code != _countryCode) {
                        _phoneController.clear();
                      }
                      _countryCode = c.code;
                    });
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.forDriver ? 'login for driver' : 'Login',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Icon(
                  Icons.phone_in_talk_rounded,
                  size: 64,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We send a login code to your email (SMS is not used).',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'your.email@example.com',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'Enter your email';
                  if (!s.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _showCountryDialPicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _countryCode,
                            style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      inputFormatters: _phoneInputFormatters,
                      decoration: InputDecoration(
                        hintText: _countryCode == '+961'
                            ? '70 123 456'
                            : 'Mobile number',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSendingCode ? null : _handleSendCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSendingCode
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Code'),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AuthSignInScreen(
                          role: widget.forDriver ? UserRole.driver : UserRole.passenger,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Log in with email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    children: [
                      const TextSpan(text: 'Don\'t have an account? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => widget.forDriver
                                    ? const CreateAccountDriverScreen()
                                    : const CreateAccountPassengerScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChangePasswordScreen(
                          allowWithoutSession: true,
                          initialEmail: _emailController.text.trim(),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final phoneForUi = phoneDigits.isEmpty
        ? '${_countryCode}00000000'
        : '$_countryCode$phoneDigits';

    setState(() => _isSendingCode = true);
    final ok = await context.read<AuthProvider>().requestLoginEmailOtp(
          email: email,
        );
    if (!mounted) return;
    setState(() => _isSendingCode = false);

    if (!ok) {
      final msg = context.read<AuthProvider>().lastError ?? 'Could not send code';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerifyScreen(
          phoneNumber: phoneForUi,
          forDriver: widget.forDriver,
          userEmail: email,
        ),
      ),
    );
  }
}
