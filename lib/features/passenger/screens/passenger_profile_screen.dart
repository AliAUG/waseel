import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/app_session_clear.dart';
import 'package:waseel/core/sign_out_confirm_dialog.dart';
import 'package:waseel/core/profile_image_provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/models/user_model.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/auth/screens/choose_role_screen.dart';
import 'package:waseel/features/passenger/screens/payment_methods_screen.dart';
import 'package:waseel/features/passenger/screens/saved_places_screen.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/help_support_screen.dart';
import 'package:waseel/features/passenger/screens/settings_screen.dart';
import 'package:waseel/features/passenger/screens/trip_history_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_shell_strings.dart';
import 'package:waseel/features/reports/screens/submit_report_screen.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthProvider>().refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = PassengerShellStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          s.profileTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user ?? _defaultUser();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _UserCard(user: user, s: s),
                const SizedBox(height: 24),
                _MenuItem(
                  icon: Icons.directions_car,
                  iconColor: AppTheme.primaryTeal,
                  title: s.myTrips,
                  subtitle: s.myTripsSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TripHistoryScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Colors.purple,
                  title: s.myDeliveries,
                  subtitle: s.myDeliveriesSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const TripHistoryScreen(deliveriesOnly: true),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.credit_card,
                  iconColor: Colors.blue,
                  title: s.paymentMethods,
                  subtitle: s.paymentMethodsSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PaymentMethodsScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.place,
                  iconColor: AppTheme.primaryTeal,
                  title: s.savedPlaces,
                  subtitle: s.savedPlacesSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SavedPlacesScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.settings,
                  iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  title: s.settings,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  iconColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  title: s.helpSupport,
                  subtitle: s.helpSupportSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.flag_outlined,
                  iconColor: Colors.orange.shade700,
                  title: s.reportIncident,
                  subtitle: s.reportIncidentSub,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SubmitReportScreen(
                          isPassengerReporter: true,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _LogoutButton(
                  label: s.logout,
                  onTap: () async {
                    final ok = await showSignOutConfirmDialog(
                      context,
                      message: s.signOutDialogMessage,
                      cancelLabel: s.signOutDialogCancel,
                      confirmLabel: s.signOutDialogConfirm,
                    );
                    if (!ok || !context.mounted) return;
                    clearSessionProviders(context);
                    await auth.logout();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const ChooseRoleScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  s.versionLine,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  UserModel _defaultUser() {
    return const UserModel(
      name: 'Passenger',
      phone: '+961 70 123 456',
      email: 'user@email.com',
      tripsCount: 28,
      deliveriesCount: 12,
      rating: 4.9,
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.s});

  final UserModel user;
  final PassengerShellStrings s;

  static Widget _buildProfileAvatar(UserModel user) {
    final bg = profileImageProvider(user.profileImagePath);
    final hasImage = bg != null;
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppTheme.primaryTeal,
      backgroundImage: bg,
      child: !hasImage
          ? Text(
              user.initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.contentPanelColor(scheme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileAvatar(user),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.phone,
            style: TextStyle(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (user.email != null && user.email!.isNotEmpty) ...[
            Text(
              user.email!,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: s.statTrips(user.tripsCount)),
              _StatChip(label: s.statDeliveries(user.deliveriesCount)),
              _StatChip(
                label: '★${user.rating}',
                showStar: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, this.showStar = false});

  final String label;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.contentInsetColor(scheme),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.contentPanelColor(scheme),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new
                  : Icons.arrow_forward_ios,
              size: 14,
              color: scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, size: 20, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
