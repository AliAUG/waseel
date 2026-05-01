import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/app_typography.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/ride_screen.dart';
import 'package:waseel/features/passenger/screens/trip_history_screen.dart';
import 'package:waseel/features/passenger/screens/passenger_profile_screen.dart';
import 'package:waseel/features/passenger/screens/wallet_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_shell_strings.dart';

class PassengerShell extends StatefulWidget {
  const PassengerShell({super.key});

  @override
  State<PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends State<PassengerShell> {
  int _currentIndex = 0;

  static const Color _accent = Color(0xFF1FA88F);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final s = PassengerShellStrings(context.watch<SettingsProvider>().language);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          RideScreen(),
          TripHistoryScreen(),
          WalletScreen(),
          PassengerProfileScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
            child: Row(
              children: [
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.home_rounded,
                    iconOutlined: Icons.home_outlined,
                    label: s.navHome,
                    selected: _currentIndex == 0,
                    accent: _accent,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.history_rounded,
                    iconOutlined: Icons.history,
                    label: s.navHistory,
                    selected: _currentIndex == 1,
                    accent: _accent,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.account_balance_wallet_rounded,
                    iconOutlined: Icons.account_balance_wallet_outlined,
                    label: s.navWallet,
                    selected: _currentIndex == 2,
                    accent: _accent,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ),
                Expanded(
                  child: _BottomNavItem(
                    icon: Icons.person_rounded,
                    iconOutlined: Icons.person_outline,
                    label: s.navProfile,
                    selected: _currentIndex == 3,
                    accent: _accent,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final IconData iconOutlined;
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const inactive = Color(0xFF7A7A7A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? icon : iconOutlined,
                size: 26,
                color: selected ? accent : inactive,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appFont(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? accent : inactive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
