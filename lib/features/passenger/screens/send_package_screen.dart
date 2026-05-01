import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';
import 'package:waseel/features/passenger/screens/searching_for_delivery_screen.dart';

class SendPackageScreen extends StatefulWidget {
  const SendPackageScreen({super.key});

  @override
  State<SendPackageScreen> createState() => _SendPackageScreenState();
}

class _SendPackageScreenState extends State<SendPackageScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _notesController = TextEditingController();
  PackageSize _packageSize = PackageSize.small;

  @override
  void initState() {
    super.initState();
    _packageSize = context.read<RideProvider>().selectedPackageSize;
    _pickupController.addListener(_onAddressChanged);
    _dropoffController.addListener(_onAddressChanged);
  }

  void _setPackageSize(PackageSize size) {
    setState(() => _packageSize = size);
    context.read<RideProvider>().setSelectedPackageSize(size);
  }

  void _onAddressChanged() => setState(() {});

  @override
  void dispose() {
    _pickupController.removeListener(_onAddressChanged);
    _dropoffController.removeListener(_onAddressChanged);
    _pickupController.dispose();
    _dropoffController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Estimated distance in km - uses 5 km default when addresses empty.
  /// In production, replace with geocoding + distance matrix API.
  double get _estimatedDistanceKm {
    final pickup = _pickupController.text.trim();
    final dropoff = _dropoffController.text.trim();
    if (pickup.isEmpty || dropoff.isEmpty) return 5.0;
    // Placeholder: longer addresses suggest different areas = more distance
    final len = pickup.length + dropoff.length;
    return (3 + (len / 4).clamp(0, 12)).toDouble();
  }

  int get _deliveryFee => calculateDeliveryFee(
        _packageSize,
        _estimatedDistanceKm,
      );

  String _estimatedDeliveryRange(PassengerFlowStrings flow) {
    final baseMin = 20;
    final sizeMin = _packageSize.index * 5;
    final distMin = (_estimatedDistanceKm * 2).round();
    final low = baseMin + sizeMin + distMin;
    return flow.sendPackageEtaRange(low, low + 10);
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          flow.sendPackageTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: AppTheme.primaryTeal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      flow.addressesLebanonOnly,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _AddressField(
              label: flow.pickupAddressLabel,
              hint: flow.pickupAddressHint,
              icon: Icons.place,
              iconColor: AppTheme.primaryTeal,
              controller: _pickupController,
            ),
            const SizedBox(height: 20),
            _AddressField(
              label: flow.dropoffAddressLabel,
              hint: flow.dropoffAddressHint,
              icon: Icons.place,
              iconColor: Colors.red,
              controller: _dropoffController,
            ),
            const SizedBox(height: 24),
            Text(
              flow.packageSizeSection,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PackageSizeCard(
                    flow: flow,
                    size: PackageSize.small,
                    isSelected: _packageSize == PackageSize.small,
                    onTap: () => _setPackageSize(PackageSize.small),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PackageSizeCard(
                    flow: flow,
                    size: PackageSize.medium,
                    isSelected: _packageSize == PackageSize.medium,
                    onTap: () => _setPackageSize(PackageSize.medium),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PackageSizeCard(
                    flow: flow,
                    size: PackageSize.large,
                    isSelected: _packageSize == PackageSize.large,
                    onTap: () => _setPackageSize(PackageSize.large),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              flow.additionalNotes,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: flow.notesHint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '📦',
                        style: TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flow.estimatedDelivery,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            _estimatedDeliveryRange(flow),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        flow.deliveryFeeLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        formatLebanesePounds(_deliveryFee),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final pickup = _pickupController.text.trim();
                  final dropoff = _dropoffController.text.trim();
                  if (pickup.isEmpty || dropoff.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            flow.deliveryAddressesRequired,
                            style: const TextStyle(color: Colors.white),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red.shade700,
                          showCloseIcon: true,
                          closeIconColor: Colors.white,
                        ),
                      );
                    return;
                  }

                  context.read<RideProvider>().setDeliveryAddresses(
                        pickup,
                        dropoff,
                        _estimatedDistanceKm,
                        specialInstructions: _notesController.text.trim(),
                      );
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SearchingForDeliveryScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(flow.requestDelivery),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.controller,
  });

  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: iconColor, size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _PackageSizeCard extends StatelessWidget {
  const _PackageSizeCard({
    required this.flow,
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  final PassengerFlowStrings flow;
  final PackageSize size;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryTeal : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '📦',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 8),
            Text(
              flow.packageSizeShort(size),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade900,
              ),
            ),
            Text(
              flow.packageWeight(size),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
