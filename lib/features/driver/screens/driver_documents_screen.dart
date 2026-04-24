import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/data/driver_api_service.dart';

class DriverDocumentsScreen extends StatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  State<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends State<DriverDocumentsScreen> {
  final _api = DriverApiService();
  final List<Map<String, dynamic>> _docs = <Map<String, dynamic>>[];

  bool _loading = true;
  bool _submitting = false;
  String? _error;

  static const _requiredTypes = <String, String>{
    'ID_FRONT_BACK': 'ID Document (Front & Back)',
    'DRIVER_LICENSE': "Driver's License",
    'VEHICLE_REGISTRATION': 'Vehicle Registration',
    'INSURANCE': 'Insurance (Optional)',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
  }

  String? get _token {
    final t = context.read<AuthProvider>().token;
    if (t == null || t.isEmpty || t == 'local-session') return null;
    return t;
  }

  bool get _isDriverRole =>
      context.read<AuthProvider>().user?.role?.toLowerCase() == 'driver';

  Future<void> _loadDocuments() async {
    final token = _token;
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'Sign in as a driver to manage documents.';
      });
      return;
    }
    if (!_isDriverRole) {
      setState(() {
        _loading = false;
        _error = 'This section is for Driver accounts only.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final docs = await _api.getDocuments(token);
      if (!mounted) return;
      setState(() {
        _docs
          ..clear()
          ..addAll(docs);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitDocumentType(String type) async {
    final token = _token;
    if (token == null || _submitting) return;
    if (!_isDriverRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must sign in with a Driver account to submit documents.'),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _api.uploadDocument(token, documentType: type, documentFiles: const <String>[]);
      if (!mounted) return;
      await _loadDocuments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document submitted for review.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = (e.statusCode == 403 || e.message.toLowerCase().contains('insufficient permissions'))
          ? 'You must sign in with a Driver account to submit documents.'
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Map<String, dynamic>? _docForType(String type) {
    for (final d in _docs) {
      if (d['documentType']?.toString() == type) return d;
    }
    return null;
  }

  DateTime? _parseDate(dynamic v) {
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Pending';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  bool _isApproved(Map<String, dynamic>? doc) =>
      doc != null && doc['approvalStatus']?.toString() == 'Approved';

  @override
  Widget build(BuildContext context) {
    final hasApprovedRequired = _requiredTypes.entries
        .where((e) => e.key != 'INSURANCE')
        .every((e) => _isApproved(_docForType(e.key)));

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
          'Documents & Verification',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDocuments,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _TopStatusCard(verified: hasApprovedRequired),
                  const SizedBox(height: 20),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      'Pull down to refresh. Tap submit/re-upload to send document type for review.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final entry in _requiredTypes.entries)
                    _DocumentCard(
                      title: entry.value,
                      status: _docForType(entry.key)?['approvalStatus']?.toString() ?? 'Pending',
                      date: _formatDate(_parseDate(_docForType(entry.key)?['updatedAt'])),
                      notes: _docForType(entry.key)?['notes']?.toString(),
                      canSubmit: !_submitting,
                      actionLabel: _docForType(entry.key) == null ? 'Submit' : 'Re-upload',
                      onAction: () => _submitDocumentType(entry.key),
                    ),
                ],
              ),
            ),
    );
  }
}

class _TopStatusCard extends StatelessWidget {
  const _TopStatusCard({required this.verified});

  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: verified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: verified ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            verified ? Icons.check_circle : Icons.pending_actions_rounded,
            size: 48,
            color: verified ? Colors.green.shade600 : Colors.orange.shade700,
          ),
          const SizedBox(height: 12),
          Text(
            verified ? 'Account Verified' : 'Verification in progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verified
                ? 'Required documents are approved.'
                : 'Submit required documents to complete verification.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.title,
    required this.status,
    required this.date,
    required this.canSubmit,
    required this.actionLabel,
    required this.onAction,
    this.notes,
  });

  final String title;
  final String status;
  final String date;
  final bool canSubmit;
  final String actionLabel;
  final VoidCallback onAction;
  final String? notes;

  bool get isApproved => status == 'Approved';

  @override
  Widget build(BuildContext context) {
    final statusColor = isApproved ? Colors.green.shade700 : Colors.orange.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isApproved ? Icons.check_circle : Icons.info,
                size: 18,
                color: statusColor,
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (notes != null && notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              notes!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: canSubmit ? onAction : null,
              icon: const Icon(Icons.upload_file, size: 16),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}
