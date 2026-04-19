import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/core/user_settings_sync.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/models/emergency_contact.dart';
import 'package:waseel/features/passenger/providers/privacy_safety_provider.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class PrivacySafetyScreen extends StatelessWidget {
  const PrivacySafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: Colors.grey.shade800,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          flow.privacySafetyTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<PrivacySafetyProvider>(
        builder: (context, privacy, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(flow.privacySectionSharing),
                _ToggleTile(
                  icon: Icons.place,
                  iconColor: AppTheme.primaryTeal,
                  title: flow.privacyShareTripTitle,
                  subtitle: flow.privacyShareTripSub,
                  value: privacy.shareTripStatus,
                  onChanged: privacyToggleWithSync(
                    context,
                    privacy.setShareTripStatus,
                  ),
                ),
                _ToggleTile(
                  icon: Icons.notifications_outlined,
                  iconColor: Colors.orange,
                  title: flow.privacyEmergencyAlerts,
                  subtitle: flow.privacyEmergencyAlertsSub,
                  value: privacy.emergencyAlerts,
                  onChanged: privacyToggleWithSync(
                    context,
                    privacy.setEmergencyAlerts,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(flow.privacySectionSettings),
                _ToggleTile(
                  icon: Icons.visibility_off_outlined,
                  iconColor: Colors.grey.shade700,
                  title: flow.privacyHidePhone,
                  subtitle: flow.privacyHidePhoneSub,
                  value: privacy.hideMyPhoneNumber,
                  onChanged: privacyToggleWithSync(
                    context,
                    privacy.setHideMyPhoneNumber,
                  ),
                ),
                _ToggleTile(
                  icon: Icons.visibility_outlined,
                  iconColor: Colors.grey.shade700,
                  title: flow.privacyShowPhoto,
                  subtitle: flow.privacyShowPhotoSub,
                  value: privacy.showProfilePicture,
                  onChanged: privacyToggleWithSync(
                    context,
                    privacy.setShowProfilePicture,
                  ),
                ),
                _ToggleTile(
                  icon: Icons.shield_outlined,
                  iconColor: Colors.blue,
                  title: flow.privacyDataCollection,
                  subtitle: flow.privacyDataCollectionSub,
                  value: privacy.dataCollection,
                  onChanged: privacyToggleWithSync(
                    context,
                    privacy.setDataCollection,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    flow.privacyInfoBanner,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionTitle(flow.privacySectionEmergencyContacts),
                Text(
                  flow.privacyEmergencyContactsHint,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                if (privacy.emergencyContacts.isNotEmpty) ...[
                  for (var i = 0; i < privacy.emergencyContacts.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          title: Text(
                            privacy.emergencyContacts[i].name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${privacy.emergencyContacts[i].phoneNumber}'
                            '${privacy.emergencyContacts[i].relationship != null && privacy.emergencyContacts[i].relationship!.trim().isNotEmpty ? ' • ${privacy.emergencyContacts[i].relationship}' : ''}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.grey.shade700,
                            ),
                            onPressed: () async {
                              privacy.removeEmergencyContactAt(i);
                              await pushEmergencyContactsToServer(context);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(flow.privacyContactRemoved),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final auth = context.read<AuthProvider>();
                      final t = auth.token;
                      if (t == null ||
                          t.isEmpty ||
                          t == 'local-session') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              flow.privacyNeedAccountForContacts,
                            ),
                          ),
                        );
                        return;
                      }
                      await showDialog<void>(
                        context: context,
                        builder: (dialogContext) => _AddEmergencyContactDialog(
                          flow: flow,
                          onSaved: (entry) async {
                            privacy.addEmergencyContact(entry);
                            await pushEmergencyContactsToServer(context);
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(flow.privacyContactSaved),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 22),
                    label: Text(flow.privacyAddEmergencyContact),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddEmergencyContactDialog extends StatefulWidget {
  const _AddEmergencyContactDialog({
    required this.flow,
    required this.onSaved,
  });

  final PassengerFlowStrings flow;
  final Future<void> Function(EmergencyContactEntry entry) onSaved;

  @override
  State<_AddEmergencyContactDialog> createState() =>
      _AddEmergencyContactDialogState();
}

class _AddEmergencyContactDialogState extends State<_AddEmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _relationship = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _relationship.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final entry = EmergencyContactEntry(
      name: _name.text.trim(),
      phoneNumber: _phone.text.trim(),
      relationship: _relationship.text.trim().isEmpty
          ? null
          : _relationship.text.trim(),
    );
    await widget.onSaved(entry);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.flow;
    return AlertDialog(
      title: Text(f.privacyAddEmergencyContact),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: f.privacyEmergencyNameLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) {
                    return f.privacyEmergencyNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: f.privacyEmergencyPhoneLabel,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? '').trim().isEmpty) {
                    return f.privacyEmergencyPhoneRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relationship,
                decoration: InputDecoration(
                  labelText: f.privacyEmergencyRelationshipLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(f.privacyEmergencyCancel),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(f.privacyEmergencySave),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryTeal.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}
