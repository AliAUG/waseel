import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/models/saved_place.dart';
import 'package:waseel/features/passenger/providers/saved_places_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() {
    final token = context.read<AuthProvider>().token;
    return context.read<SavedPlacesProvider>().refresh(token: token);
  }

  Future<void> _showEditor({SavedPlace? existing}) async {
    final auth = context.read<AuthProvider>();
    final places = context.read<SavedPlacesProvider>();
    final result = await showDialog<_PlaceFormResult>(
      context: context,
      builder: (ctx) => _PlaceFormDialog(
        existing: existing,
        flow: PassengerFlowStrings(ctx.read<SettingsProvider>().language),
      ),
    );
    if (result == null || !mounted) return;
    try {
      if (existing != null) {
        await places.updatePlace(
          existing.id,
          label: result.label,
          address: result.address,
          token: auth.token,
        );
      } else {
        await places.addPlace(
          label: result.label,
          address: result.address,
          token: auth.token,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          flow.savedPlacesTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Theme.of(context).colorScheme.onSurface,
            onPressed: _refresh,
          ),
        ],
      ),
      body: Consumer<SavedPlacesProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                if (provider.loading && provider.places.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (provider.loadError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      provider.loadError!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                if (!provider.loading && provider.places.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        flow.savedPlacesEmpty,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ...provider.places.map(
                  (place) => _SavedPlaceCard(
                    place: place,
                    flow: flow,
                    onEdit: () => _showEditor(existing: place),
                    onDelete: () async {
                      try {
                        await provider.removePlace(
                          place.id,
                          token: context.read<AuthProvider>().token,
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _AddNewPlaceButton(
                  flow: flow,
                  onTap: () => _showEditor(),
                ),
                const SizedBox(height: 24),
                _QuickTips(flow: flow),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlaceFormResult {
  _PlaceFormResult({
    required this.label,
    required this.address,
  });

  final String label;
  final String address;
}

class _PlaceFormDialog extends StatefulWidget {
  const _PlaceFormDialog({this.existing, required this.flow});

  final SavedPlace? existing;
  final PassengerFlowStrings flow;

  @override
  State<_PlaceFormDialog> createState() => _PlaceFormDialogState();
}

class _PlaceFormDialogState extends State<_PlaceFormDialog> {
  final _labelCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _labelCtrl.text = e.name;
      _addressCtrl.text = e.address;
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flow;
    return AlertDialog(
      title: Text(
        widget.existing == null
            ? f.savedPlacesAddDialogTitle
            : f.savedPlacesEditDialogTitle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _labelCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: f.savedPlacesFieldPlaceName,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: f.savedPlacesFieldAddress,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(f.buttonCancel),
        ),
        FilledButton(
          onPressed: () {
            final label = _labelCtrl.text.trim();
            final addr = _addressCtrl.text.trim();
            if (label.isEmpty || addr.isEmpty) return;
            Navigator.pop(
              context,
              _PlaceFormResult(label: label, address: addr),
            );
          },
          child: Text(f.buttonSave),
        ),
      ],
    );
  }
}

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({
    required this.place,
    required this.flow,
    required this.onEdit,
    required this.onDelete,
  });

  final SavedPlace place;
  final PassengerFlowStrings flow;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final typeX = place.type;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: typeX.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeX.icon, size: 26, color: typeX.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  place.address,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (context) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: Text(flow.savedPlacesSheetEdit),
                        onTap: () {
                          Navigator.pop(context);
                          onEdit();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red.shade600),
                        title: Text(
                          flow.savedPlacesSheetDelete,
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await onDelete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddNewPlaceButton extends StatelessWidget {
  const _AddNewPlaceButton({required this.flow, required this.onTap});

  final PassengerFlowStrings flow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 24, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              flow.savedPlacesAddNew,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTips extends StatelessWidget {
  const _QuickTips({required this.flow});

  final PassengerFlowStrings flow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            flow.savedPlacesQuickTips,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _TipBullet(flow.savedPlacesTipServer),
          _TipBullet(flow.savedPlacesTipTypes),
          _TipBullet(flow.savedPlacesTipPull),
        ],
      ),
    );
  }
}

class _TipBullet extends StatelessWidget {
  const _TipBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
