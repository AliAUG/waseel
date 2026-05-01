import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/post_login_sync.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_settings_strings.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    this.allowWithoutSession = false,
    this.initialEmail,
  });

  /// Forgot-password from login: show form without JWT; after success go to shell.
  final bool allowWithoutSession;

  /// Pre-fill email (e.g. from login screen).
  final String? initialEmail;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final TextEditingController _emailController;
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _codeSent = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final fromAuth = context.read<AuthProvider>().user?.email?.trim() ?? '';
    final fromArg = widget.initialEmail?.trim() ?? '';
    final email = fromArg.isNotEmpty ? fromArg : fromAuth;
    _emailController = TextEditingController(text: email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _looksLikeEmail(String s) {
    final t = s.trim();
    return t.contains('@') && t.contains('.') && t.length > 5;
  }

  Future<void> _sendCode(PassengerSettingsStrings s) async {
    final email = _emailController.text.trim();
    if (!_looksLikeEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.changePasswordInvalidEmail)),
      );
      return;
    }
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.requestPasswordReset(email: email);
    if (!mounted) return;
    if (!ok) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.lastError ?? 'Request failed')),
      );
      return;
    }
    setState(() {
      _submitting = false;
      _codeSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.changePasswordCodeSent)),
    );
  }

  Future<void> _updatePassword(PassengerSettingsStrings s) async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final pw = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.changePasswordCodeHint)),
      );
      return;
    }
    if (pw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.changePasswordTooShort)),
      );
      return;
    }
    if (pw != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.changePasswordMismatch)),
      );
      return;
    }
    setState(() => _submitting = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyPasswordReset(
      email: email,
      code: code,
      newPassword: pw,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.lastError ?? 'Request failed')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.changePasswordSuccess)),
    );
    if (!mounted) return;
    if (widget.allowWithoutSession) {
      await syncShellDataAfterLogin(context);
      if (!mounted) return;
      final role = context.read<AuthProvider>().user?.role;
      final route = role == 'Driver' ? '/driver' : '/passenger';
      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final s = PassengerSettingsStrings(settings.language);
    final auth = context.watch<AuthProvider>();
    final t = auth.token;
    final hasRealToken =
        t != null && t.isNotEmpty && t != 'local-session';
    final canShowForm = widget.allowWithoutSession || hasRealToken;

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
          s.changePasswordScreenTitle,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!canShowForm) ...[
              Text(
                s.changePasswordNeedRealSession,
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ] else ...[
              Text(
                s.changePasswordEmailHint,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'email@example.com',
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
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting || auth.isLoading
                      ? null
                      : () => _sendCode(s),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting && !_codeSent
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(s.changePasswordSendCode),
                ),
              ),
              if (_codeSent) ...[
                const SizedBox(height: 28),
                Text(
                  s.changePasswordCodeHint,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
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
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: s.changePasswordNewHint,
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
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: s.changePasswordConfirmHint,
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
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting || auth.isLoading
                        ? null
                        : () => _updatePassword(s),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _submitting && _codeSent
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(s.changePasswordSubmit),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
