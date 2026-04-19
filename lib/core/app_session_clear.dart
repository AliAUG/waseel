import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/passenger/providers/ride_provider.dart';
import 'package:waseel/features/passenger/providers/saved_places_provider.dart';
import 'package:waseel/features/passenger/providers/wallet_provider.dart';

/// Clears in-memory trip/wallet/saved-places/driver state before [AuthProvider.logout].
/// Call while still logged in so [SavedPlacesProvider.refresh] can use the token if needed;
/// with `token: null` it falls back to the local demo list synchronously.
void clearSessionProviders(BuildContext context) {
  context.read<RideProvider>().clearRide();
  context.read<WalletProvider>().resetForLogout();
  context.read<SavedPlacesProvider>().refresh(token: null);
  context.read<DriverProvider>().resetForLogout();
}
