import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
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
    required this.simulateButton,
    required this.onSimulate,
    this.primaryButton,
    this.primaryButtonLabel,
  });

  final String driverName;
  final double driverRating;
  final String driverVehicle;
  final String driverLocation;
  final String eta;
  final String simulateButton;
  final VoidCallback onSimulate;
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
            color: Theme.of(context).colorScheme.onSurface,
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
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSimulate,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              child: Text(simulateButton),
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
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.contentPanelColor(scheme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: scheme.primaryContainer,
            child: const Text('👤', style: TextStyle(fontSize: 32)),
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
                    color: scheme.onSurface,
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
                          color: scheme.onSurface,
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
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
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
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.contentPanelColor(scheme),
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Icon(icon, color: scheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
