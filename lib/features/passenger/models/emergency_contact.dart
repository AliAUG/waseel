/// One entry in [UserSettings.emergencyContacts] on the server.
class EmergencyContactEntry {
  const EmergencyContactEntry({
    required this.name,
    required this.phoneNumber,
    this.relationship,
  });

  final String name;
  final String phoneNumber;
  final String? relationship;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name.trim(),
        'phoneNumber': phoneNumber.trim(),
        if (relationship != null && relationship!.trim().isNotEmpty)
          'relationship': relationship!.trim(),
      };

  factory EmergencyContactEntry.fromJson(Map<String, dynamic> m) {
    return EmergencyContactEntry(
      name: m['name']?.toString() ?? '',
      phoneNumber: m['phoneNumber']?.toString() ?? '',
      relationship: m['relationship']?.toString(),
    );
  }
}
