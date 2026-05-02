import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class DeliveryInfoContent extends StatelessWidget {
  const DeliveryInfoContent({
    super.key,
    required this.driverName,
    required this.driverRating,
    required this.driverVehicle,
    required this.driverLocation,
    required this.eta,
    this.simulateButton,
    this.onSimulate,
    this.primaryButton,
    this.primaryButtonLabel,
  });

  final String driverName;
  final double driverRating;
  final String driverVehicle;
  final String driverLocation;
  final String eta;
  final String? simulateButton;
  final VoidCallback? onSimulate;
  final VoidCallback? primaryButton;
  final String? primaryButtonLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eta,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 20),
        DeliveryDriverCard(
          name: driverName,
          rating: driverRating,
          vehicle: driverVehicle,
          location: driverLocation,
        ),
        const SizedBox(height: 24),
        DeliveryActionButtons(),
        const SizedBox(height: 20),
        DeliveryEmergencyButton(),
        const SizedBox(height: 32),
        if (primaryButton != null && primaryButtonLabel != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: primaryButton,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(primaryButtonLabel!),
            ),
          )
        else if (onSimulate != null &&
            simulateButton != null &&
            simulateButton!.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSimulate,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey.shade400),
                foregroundColor: Colors.grey.shade700,
              ),
              child: Text(simulateButton!),
            ),
          ),
      ],
    );
  }
}

class DeliveryDriverCard extends StatelessWidget {
  const DeliveryDriverCard({
    super.key,
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.location,
  });

  final String name;
  final double rating;
  final String vehicle;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.blue.shade100,
            child: Text('👤', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                if (rating > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  vehicle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DeliveryActionButton(icon: Icons.phone, label: flow.callDriver),
        DeliveryActionButton(
          icon: Icons.chat_bubble_outline,
          label: flow.chatDriver,
        ),
        DeliveryActionButton(icon: Icons.share, label: flow.shareTrip),
      ],
    );
  }
}

class DeliveryActionButton extends StatelessWidget {
  const DeliveryActionButton({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(icon, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class DeliveryEmergencyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(Icons.shield_outlined, color: Colors.red.shade700, size: 22),
        label: Text(
          flow.emergency,
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.red.shade300),
        ),
      ),
    );
  }
}
