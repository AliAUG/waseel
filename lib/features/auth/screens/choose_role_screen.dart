import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waseel/core/app_typography.dart';
import 'package:waseel/features/auth/models/user_role.dart';
import 'package:waseel/features/auth/screens/create_account_driver_screen.dart';
import 'package:waseel/features/auth/screens/create_account_passenger_screen.dart';

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({
    super.key,
    this.initialRole,
  });

  final UserRole? initialRole;

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  static const Color _brandGreen = Color(0xFF006D5B);
  static const Color _selectedCardBg = Color(0xFFE8F5F1);
  static const Color _unselectedCardBg = Color(0xFFF7F7F6);
  static const Color _iconBoxSelected = Color(0xFFD4EDE6);
  static const Color _iconBoxUnselected = Color(0xFFEBEBEA);

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? UserRole.passenger;
  }

  late UserRole _selectedRole;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/role_select_map.png'),
                fit: BoxFit.cover,
                alignment: Alignment(0, -0.05),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: Colors.grey.shade900,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'لوين واصل',
                    style: GoogleFonts.notoSansArabic(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: _brandGreen,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select how you want to use Lwein Wasel',
                    style: context.appFont(
                      fontSize: 15,
                      height: 1.35,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _RoleCard(
                            title: 'Passenger',
                            subtitle: 'Book rides and send packages',
                            isSelected: _selectedRole == UserRole.passenger,
                            onTap: () =>
                                setState(() => _selectedRole = UserRole.passenger),
                            iconSlot: _passengerIcon(
                              _selectedRole == UserRole.passenger,
                            ),
                            selectedBg: _selectedCardBg,
                            unselectedBg: _unselectedCardBg,
                            iconBoxSelected: _iconBoxSelected,
                            iconBoxUnselected: _iconBoxUnselected,
                            useCheckmark: true,
                          ),
                          const SizedBox(height: 14),
                          _RoleCard(
                            title: 'Driver',
                            subtitle: 'Earn money by driving',
                            isSelected: _selectedRole == UserRole.driver,
                            onTap: () =>
                                setState(() => _selectedRole = UserRole.driver),
                            iconSlot: _driverIcon(
                              _selectedRole == UserRole.driver,
                            ),
                            selectedBg: _selectedCardBg,
                            unselectedBg: _unselectedCardBg,
                            iconBoxSelected: _iconBoxSelected,
                            iconBoxUnselected: _iconBoxUnselected,
                            useCheckmark: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 20 + bottom),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => _selectedRole == UserRole.driver
                                  ? const CreateAccountDriverScreen()
                                  : const CreateAccountPassengerScreen(),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _brandGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Continue',
                          style: context.appFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passengerIcon(bool selected) {
    final c = selected ? _brandGreen : Colors.grey.shade600;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Icon(Icons.directions_car_filled_rounded, color: c, size: 28),
        Positioned(
          top: -6,
          child: Icon(Icons.inventory_2_rounded, color: c, size: 14),
        ),
      ],
    );
  }

  Widget _driverIcon(bool selected) {
    final c = selected ? _brandGreen : Colors.grey.shade600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.directions_car_filled_rounded, color: c, size: 22),
        const SizedBox(width: 2),
        Icon(Icons.local_shipping_rounded, color: c, size: 22),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.iconSlot,
    required this.selectedBg,
    required this.unselectedBg,
    required this.iconBoxSelected,
    required this.iconBoxUnselected,
    required this.useCheckmark,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget iconSlot;
  final Color selectedBg;
  final Color unselectedBg;
  final Color iconBoxSelected;
  final Color iconBoxUnselected;
  final bool useCheckmark;

  static const Color _brandGreen = Color(0xFF006D5B);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : unselectedBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? _brandGreen : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? iconBoxSelected : iconBoxUnselected,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: iconSlot),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.appFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: context.appFont(
                        fontSize: 14,
                        height: 1.35,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (useCheckmark && isSelected)
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _brandGreen,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                )
              else
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
