import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waseel/core/app_typography.dart';
import 'package:waseel/features/auth/screens/choose_role_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color _darkTeal = Color(0xFF006D5B);
  static const Color _mint = Color(0xFF00A896);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/welcome_map_north.png',
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment(0, -0.12),
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 12 - (16 + bottomInset),
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _BrandMark(),
                                  const SizedBox(height: 20),
                                  _BilingualGreeting(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'لوين واصل',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1A1A1A),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Your premier partner for seamless rides and swift deliveries across all the north of Lebanon.',
                                    textAlign: TextAlign.center,
                                    style: context.appFont(
                                      fontSize: 14,
                                      height: 1.45,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  const _FeatureRow(
                                    icon: Icons.directions_car_rounded,
                                    label: 'Rides',
                                  ),
                                  const SizedBox(height: 12),
                                  const _FeatureRow(
                                    icon: Icons.inventory_2_outlined,
                                    label: 'Deliveries',
                                  ),
                                  const SizedBox(height: 12),
                                  const _FeatureRow(
                                    icon: Icons.schedule_rounded,
                                    label: 'Real-time tracking',
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'By continuing, you agree to our Terms & Privacy Policy.',
                                    textAlign: TextAlign.center,
                                    style: context.appFont(
                                      fontSize: 11,
                                      height: 1.35,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _GradientCta(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ChooseRoleScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: WelcomeScreen._darkTeal.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: WelcomeScreen._darkTeal.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_rounded,
                size: 18,
                color: WelcomeScreen._darkTeal.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 2),
              const Icon(
                Icons.directions_car_filled_rounded,
                size: 32,
                color: WelcomeScreen._darkTeal,
              ),
              const SizedBox(height: 4),
              Text(
                'لوين واصل',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: WelcomeScreen._darkTeal,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BilingualGreeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Marhaban ',
            style: context.appFont(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: '!مرحباً بكم ',
            style: GoogleFonts.cairo(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          TextSpan(
            text: 'to Lwein Wasel',
            style: context.appFont(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: WelcomeScreen._darkTeal),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: context.appFont(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientCta extends StatelessWidget {
  const _GradientCta({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                WelcomeScreen._darkTeal,
                WelcomeScreen._mint,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeScreen._darkTeal.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Get Started',
                textAlign: TextAlign.center,
                style: context.appFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
