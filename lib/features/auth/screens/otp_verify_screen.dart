import 'package:flutter/material.dart';
import 'package:waseel/core/post_login_sync.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({
    super.key,
    required this.phoneNumber,
    this.forDriver = false,
    this.userName,
    this.userEmail,
  });

  final String phoneNumber;
  final bool forDriver;
  final String? userName;
  final String? userEmail;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _isResending = false;

  String get _maskedPhone {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return widget.phoneNumber;
    return '+961${digits.substring(0, 2)} XX XXX ${digits.substring(5)}';
  }

  String get _destinationLabel {
    final email = widget.userEmail?.trim();
    if (email != null && email.isNotEmpty) {
      final parts = email.split('@');
      if (parts.length == 2 && parts.first.isNotEmpty) {
        final name = parts.first;
        final maskedName = name.length <= 2
            ? '${name[0]}*'
            : '${name.substring(0, 2)}***';
        return '$maskedName@${parts[1]}';
      }
      return email;
    }
    return _maskedPhone;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.forDriver ? 'OTP driver' : 'OTP for login',
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
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // light green circle
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smartphone_rounded,
                size: 44,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Enter verification code',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a code to $_destinationLabel',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (index) => _OtpBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    }
                  },
                  onBackspace: () {
                    if (index > 0 && _controllers[index].text.isEmpty) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ListenableBuilder(
                listenable: Listenable.merge(_controllers),
                builder: (context, _) {
                  final isComplete = _otpCode.length == 6;
                  return ElevatedButton(
                    onPressed: (isComplete && !_isVerifying) ? _handleVerify : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: isComplete
                          ? AppTheme.primaryTeal
                          : AppTheme.primaryTeal.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.primaryTeal.withValues(alpha: 0.4),
                      disabledForegroundColor: Colors.white,
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verify Code'),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Didn\'t receive the code?',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _handleResendCode,
              child: Text(
                _isResending ? 'Sending…' : 'Resend code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _isResending
                      ? AppTheme.primaryTeal.withValues(alpha: 0.5)
                      : AppTheme.primaryTeal,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _handleVerify() async {
    if (_otpCode.length != 6 || _isVerifying) return;

    setState(() => _isVerifying = true);
    final auth = context.read<AuthProvider>();

    // Registration: verify email + code after sign-up.
    if (widget.userName != null && widget.userEmail != null) {
      final ok = await auth.verifyRegistrationOtp(
        email: widget.userEmail!,
        code: _otpCode,
      );
      if (!mounted) return;
      setState(() => _isVerifying = false);
      if (!ok) {
        final msg = auth.lastError ?? 'OTP verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        return;
      }
      await syncShellDataAfterLogin(context);
      if (!mounted) return;
      final route = widget.forDriver ? '/driver' : '/passenger';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
      return;
    }

    // Login: email OTP (backend has no SMS).
    if (widget.userEmail != null && widget.userEmail!.trim().isNotEmpty) {
      final ok = await auth.verifyLoginEmailOtp(
        email: widget.userEmail!.trim(),
        code: _otpCode,
      );
      if (!mounted) return;
      setState(() => _isVerifying = false);
      if (!ok) {
        final msg = auth.lastError ?? 'OTP verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        return;
      }
      await syncShellDataAfterLogin(context);
      if (!mounted) return;
      final userRole = auth.user?.role;
      final isDriver = userRole == 'Driver' ||
          (userRole == null && widget.forDriver);
      final route = isDriver ? '/driver' : '/passenger';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
      return;
    }

    // No email: legacy mock (SMS not implemented).
    await auth.setUserFromLogin(phone: widget.phoneNumber);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    await syncShellDataAfterLogin(context);
    if (!mounted) return;
    final route = widget.forDriver ? '/driver' : '/passenger';
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  }

  Future<void> _handleResendCode() async {
    if (_isResending) return;
    final email = widget.userEmail?.trim();
    if (email == null || email.isEmpty) return;

    setState(() => _isResending = true);
    final auth = context.read<AuthProvider>();
    bool ok;
    if (widget.userName != null) {
      ok = await auth.requestRegistrationEmailOtp(email: email);
    } else {
      ok = await auth.requestLoginEmailOtp(email: email);
    }
    if (!mounted) return;
    setState(() => _isResending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'New code sent to your email'
              : (auth.lastError ?? 'Could not resend code'),
        ),
      ),
    );
  }
}

class _OtpBox extends StatefulWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(String) onChanged;
  final VoidCallback onBackspace;

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          widget.onChanged(value);
          if (value.isEmpty) widget.onBackspace();
        },
        onTap: () {
          widget.controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: widget.controller.text.length,
          );
        },
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryTeal,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
