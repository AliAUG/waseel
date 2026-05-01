import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/app_session_clear.dart';
import 'package:waseel/core/profile_image_provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/models/user_model.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/auth/screens/choose_role_screen.dart';
import 'package:waseel/features/driver/models/driver_vehicle.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/driver/screens/driver_documents_screen.dart';
import 'package:waseel/features/driver/screens/driver_notifications_screen.dart';
import 'package:waseel/features/driver/screens/driver_earnings_screen.dart';
import 'package:waseel/features/driver/screens/driver_job_history_screen.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/driver/screens/driver_settings_screen.dart';
import 'package:waseel/features/passenger/screens/help_support_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<AuthProvider, DriverProvider>(
        builder: (context, auth, driver, _) {
          final user = auth.user ?? _defaultUser();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                _DriverCard(user: user, driver: driver),
                const SizedBox(height: 20),
                _VehicleSection(vehicle: driver.vehicle),
                const SizedBox(height: 24),
                _MenuItem(
                  icon: Icons.verified_user,
                  iconColor: Colors.green,
                  title: 'Documents & Verification',
                  subtitle: 'Verified',
                  subtitleColor: Colors.green.shade700,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DriverDocumentsScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.account_balance_wallet,
                  iconColor: Colors.blue,
                  title: 'Earnings & Wallet',
                  subtitle: formatLebanesePounds(driver.totalEarnings),
                  subtitleColor: AppTheme.primaryTeal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DriverEarningsScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.history,
                  iconColor: AppTheme.primaryTeal,
                  title: 'Job History',
                  subtitle: '${driver.totalJobs} completed jobs',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DriverJobHistoryScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  iconColor: AppTheme.primaryTeal,
                  title: 'Notifications',
                  subtitle: 'Ride requests, earnings & more',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DriverNotificationsScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.settings,
                  iconColor: Colors.grey.shade700,
                  title: 'Settings',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DriverSettingsScreen(),
                      ),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  iconColor: Colors.grey.shade700,
                  title: 'Support & Help',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                _LogoutButton(
                  onTap: () async {
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
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
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
      name: 'Driver',
      phone: '+961 70 123 456',
      email: 'driver@email.com',
      tripsCount: 342,
      deliveriesCount: 0,
      rating: 4.9,
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.user,
    required this.driver,
  });

  final UserModel user;
  final DriverProvider driver;

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.phone,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (user.email != null && user.email!.isNotEmpty)
            Text(
              user.email!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: '★${driver.avgRating}'),
              _StatChip(label: '${driver.totalJobs} Total jobs'),
              _StatChip(label: '${driver.memberSince} Member'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }
}

class _VehicleSection extends StatelessWidget {
  const _VehicleSection({
    required this.vehicle,
  });

  final DriverVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car, size: 22, color: AppTheme.primaryTeal),
              const SizedBox(width: 8),
              Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _VehicleRow(label: 'Make & Model', value: vehicle.makeModel),
          _VehicleRow(label: 'Year', value: '${vehicle.year}'),
          _VehicleRow(label: 'Color', value: vehicle.color),
          _VehicleRow(label: 'Plate Number', value: vehicle.plateNumber),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
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
    this.subtitleColor,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
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
                      color: Colors.grey.shade900,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor ?? Colors.grey.shade600,
                        fontWeight: subtitleColor != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
