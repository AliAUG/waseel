import 'package:flutter/material.dart';
import 'package:waseel/core/app_typography.dart';
import 'package:waseel/features/auth/models/user_role.dart';
import 'package:waseel/features/auth/screens/auth_sign_in_screen.dart';
import 'package:waseel/features/driver/screens/driver_shell.dart';
import 'package:waseel/features/passenger/screens/passenger_shell.dart';

class AuthSignUpScreen extends StatelessWidget {
  const AuthSignUpScreen({
    super.key,
    required this.role,
  });

  final UserRole role;

  bool get _isDriver => role == UserRole.driver;

  @override
  Widget build(BuildContext context) {
    final title = _isDriver ? 'Driver Sign Up' : 'Passenger Sign Up';
    final subtitle = _isDriver
        ? 'Create your driver account'
        : 'Create your passenger account';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: context.appFont(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: context.appFont(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 26),
              _AuthField(hint: 'Full name', icon: Icons.person_outline),
              const SizedBox(height: 12),
              _AuthField(hint: 'Phone number', icon: Icons.phone_outlined),
              const SizedBox(height: 12),
              _AuthField(hint: 'Email (optional)', icon: Icons.email_outlined),
              const SizedBox(height: 12),
              _AuthField(
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            _isDriver ? const DriverShell() : const PassengerShell(),
                      ),
                      (_) => false,
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'or',
                      style: context.appFont(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 14),
              _SocialButton(
                icon: Icons.g_mobiledata_rounded,
                label: 'Continue with Google',
                onTap: () {},
              ),
              const SizedBox(height: 10),
              _SocialButton(
                icon: Icons.apple_rounded,
                label: 'Continue with Apple',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have account? ',
                      style: context.appFont(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AuthSignInScreen(role: role),
                          ),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.88),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      icon: Icon(icon, size: 22),
      label: Text(label),
    );
  }
}
