import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/models/ride_type.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';
import 'package:waseel/features/passenger/screens/notification_inbox_screen.dart';
import 'package:waseel/features/passenger/screens/privacy_safety_screen.dart';
import 'package:waseel/features/passenger/screens/select_location_screen.dart';
import 'package:waseel/features/passenger/screens/send_package_screen.dart';

/// Passenger home — light layout matching the reference (sans-serif, vertical ride cards).
class RideScreen extends StatefulWidget {
  const RideScreen({super.key});

  static const Color accentTeal = Color(0xFF30907A);

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<RideProvider>();
      p.loadRideTypesFromBackend();
      if (p.selectedRideType == null) {
        p.setSelectedRideType(RideType.economy);
      }
    });
  }

  void _openSearch() {
    final ride = context.read<RideProvider>();
    if (ride.isDelivery) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SendPackageScreen(),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SelectLocationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/home_map_bg.png',
          fit: BoxFit.cover,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.74),
                Colors.white.withValues(alpha: 0.82),
              ],
            ),
          ),
        ),
        Consumer<RideProvider>(
        builder: (context, ride, _) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, top + 12, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _HomeHeader(title: flow.homeTitle),
                    const SizedBox(height: 20),
                    _LightSearchBar(
                      hint: ride.isDelivery
                          ? flow.searchHintDelivery
                          : flow.searchHintRide,
                      onTap: _openSearch,
                    ),
                    const SizedBox(height: 16),
                    _PillRideDeliveryToggle(
                      rideLabel: flow.pillRide,
                      deliveryLabel: flow.pillDelivery,
                      isDelivery: ride.isDelivery,
                      onRide: () => ride.setIsDelivery(false),
                      onDelivery: () => ride.setIsDelivery(true),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ride.isDelivery
                                ? flow.choosePackageSize
                                : flow.chooseRide,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        if (!ride.isDelivery && ride.rideTypesLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: RideScreen.accentTeal,
                            ),
                          ),
                      ],
                    ),
                    if (!ride.isDelivery && ride.rideTypesError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        flow.offlineRideTypesError(ride.rideTypesError!),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF888888),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 14),
                    if (ride.isDelivery)
                      ...PackageSize.values.map(
                        (size) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DeliveryPackageListCard(
                            flow: flow,
                            size: size,
                            distanceKm: ride.deliveryDistanceKm,
                            selected: ride.selectedPackageSize == size,
                            onTap: () {
                              ride.setSelectedPackageSize(size);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SendPackageScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      ...ride.homeRideTypes.map(
                        (type) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RideOptionListCard(
                            arabic: flow.isArabic,
                            type: type,
                            selected: ride.selectedRideType?.category ==
                                type.category,
                            onTap: () {
                              ride.setSelectedRideType(type);
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SelectLocationScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF111111),
              letterSpacing: 0.4,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const NotificationInboxScreen(),
            ),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
          color: const Color(0xFF424242),
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const PrivacySafetyScreen(),
            ),
          ),
          icon: const Icon(Icons.shield_outlined),
          color: const Color(0xFF424242),
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const SelectLocationScreen(),
            ),
          ),
          icon: const Icon(Icons.my_location),
          color: const Color(0xFF424242),
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ],
    );
  }
}

class _LightSearchBar extends StatelessWidget {
  const _LightSearchBar({
    required this.hint,
    required this.onTap,
  });

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8E8E8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.search, color: Colors.grey.shade600, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hint,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
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

class _PillRideDeliveryToggle extends StatelessWidget {
  const _PillRideDeliveryToggle({
    required this.rideLabel,
    required this.deliveryLabel,
    required this.isDelivery,
    required this.onRide,
    required this.onDelivery,
  });

  final String rideLabel;
  final String deliveryLabel;
  final bool isDelivery;
  final VoidCallback onRide;
  final VoidCallback onDelivery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PillChip(
              label: rideLabel,
              selected: !isDelivery,
              onTap: onRide,
            ),
          ),
          Expanded(
            child: _PillChip(
              label: deliveryLabel,
              selected: isDelivery,
              onTap: onDelivery,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? RideScreen.accentTeal : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : const Color(0xFF555555),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _tintForPackage(PackageSize size) {
  switch (size) {
    case PackageSize.small:
      return const Color(0xFFFFE4E4);
    case PackageSize.medium:
      return const Color(0xFFDCEFFF);
    case PackageSize.large:
      return const Color(0xFFEDE7FF);
  }
}

Color _accentForPackage(PackageSize size) {
  switch (size) {
    case PackageSize.small:
      return const Color(0xFFE53935);
    case PackageSize.medium:
      return const Color(0xFF2196F3);
    case PackageSize.large:
      return const Color(0xFF9C27B0);
  }
}

class _DeliveryPackageListCard extends StatelessWidget {
  const _DeliveryPackageListCard({
    required this.flow,
    required this.size,
    required this.distanceKm,
    required this.selected,
    required this.onTap,
  });

  final PassengerFlowStrings flow;
  final PackageSize size;
  final double distanceKm;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fee = calculateDeliveryFee(size, distanceKm);
    final eta = flow.deliveryEtaLine(size, distanceKm);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: selected ? 2 : 0.5,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? RideScreen.accentTeal
                  : Colors.black.withValues(alpha: 0.06),
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _tintForPackage(size),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: _accentForPackage(size),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flow.packageTitle(size),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${flow.packageWeight(size)} · $eta',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatLebanesePounds(fee),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _tintForRide(RideType type) {
  switch (type.category) {
    case RideCategory.economy:
      return const Color(0xFFFFE4E4);
    case RideCategory.comfort:
      return const Color(0xFFDCEFFF);
    case RideCategory.luxury:
      return const Color(0xFFEDE7FF);
  }
}

class _RideOptionListCard extends StatelessWidget {
  const _RideOptionListCard({
    required this.arabic,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final bool arabic;
  final RideType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: selected ? 2 : 0.5,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? RideScreen.accentTeal
                  : Colors.black.withValues(alpha: 0.06),
              width: selected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _tintForRide(type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: (type.category == RideCategory.economy ||
                        type.category == RideCategory.comfort ||
                        type.category == RideCategory.luxury)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ClipRect(
                          child: Transform.scale(
                            scale: 2.6,
                            child: Image.asset(
                              type.category == RideCategory.economy
                                  ? 'assets/images/economy_car_custom.png'
                                  : (type.category == RideCategory.comfort
                                      ? 'assets/images/economy_car_custom_v2.png'
                                      : 'assets/images/luxury_car_custom.png'),
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        type.icon,
                        color: type.color,
                        size: 26,
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arabic ? type.arabicLabel : type.label,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.etaForLocale(arabic),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                type.price,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
