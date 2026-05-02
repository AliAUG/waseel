import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/models/driver_job.dart';
import 'package:waseel/features/driver/providers/driver_provider.dart';
import 'package:waseel/features/passenger/data/trip_api_service.dart';
import 'package:waseel/features/passenger/models/trip_history.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';
import 'package:waseel/features/reports/data/reports_api_service.dart';
import 'package:waseel/features/reports/models/report_category.dart';
import 'package:waseel/features/reports/strings/report_strings.dart';

/// Passenger reports a driver, or driver reports a passenger.
/// Data is sent to [BackendEndpoints.reports] for an admin dashboard (backend to implement).
class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({
    super.key,
    required this.isPassengerReporter,
  });

  final bool isPassengerReporter;

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _targetCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _api = TripApiService();
  final _reports = ReportsApiService();

  List<TripHistory> _trips = [];
  bool _tripsLoading = true;
  String? _selectedTripId;
  String? _selectedJobId;
  ReportCategory _category = ReportCategory.safety;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTripsIfNeeded());
  }

  Future<void> _loadTripsIfNeeded() async {
    if (!widget.isPassengerReporter) {
      setState(() => _tripsLoading = false);
      return;
    }
    final auth = context.read<AuthProvider>();
    final t = auth.token;
    if (t == null || t.isEmpty || t == 'local-session') {
      setState(() {
        _tripsLoading = false;
        _trips = [];
      });
      return;
    }
    try {
      final list = await _api.getTripHistory(t);
      if (!mounted) return;
      setState(() {
        _trips = list;
        _tripsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _tripsLoading = false);
    }
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _onTripSelected(String? id) {
    setState(() {
      _selectedTripId = id;
      if (id == null || id.isEmpty) {
        return;
      }
      TripHistory? trip;
      for (final t in _trips) {
        if (t.id == id) {
          trip = t;
          break;
        }
      }
      if (trip != null && trip.hasAssignedDriver) {
        _targetCtrl.text = trip.driverName;
      }
    });
  }

  void _onJobSelected(String? id) {
    setState(() {
      _selectedJobId = id;
      _targetCtrl.clear();
    });
  }

  Future<void> _submit(ReportStrings r, PassengerFlowStrings flow) async {
    final details = _detailsCtrl.text.trim();
    if (details.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.detailsTooShort)),
      );
      return;
    }
    final name = _targetCtrl.text.trim();
    final hasLink = widget.isPassengerReporter
        ? (_selectedTripId != null && _selectedTripId!.isNotEmpty)
        : (_selectedJobId != null && _selectedJobId!.isNotEmpty);
    if (name.isEmpty && !hasLink) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.needReportedName)),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null || token.isEmpty || token == 'local-session') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.needLogin)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      String? tripType;
      if (widget.isPassengerReporter && _selectedTripId != null) {
        TripHistory? trip;
        for (final t in _trips) {
          if (t.id == _selectedTripId) {
            trip = t;
            break;
          }
        }
        tripType = trip?.tripType == TripType.delivery ? 'delivery' : 'ride';
      } else if (!widget.isPassengerReporter && _selectedJobId != null) {
        DriverJob? job;
        for (final j in context.read<DriverProvider>().jobs) {
          if (j.id == _selectedJobId) {
            job = j;
            break;
          }
        }
        tripType = job?.type == JobType.delivery ? 'delivery' : 'ride';
      }

      await _reports.submitReport(
        token: token,
        reporterRole: widget.isPassengerReporter ? 'passenger' : 'driver',
        reportedRole: widget.isPassengerReporter ? 'driver' : 'passenger',
        category: _category,
        description: details,
        tripOrJobId: widget.isPassengerReporter ? _selectedTripId : _selectedJobId,
        tripType: tripType,
        reportedUserName: name.isNotEmpty ? name : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(r.success)),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
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

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().language;
    final r = ReportStrings(lang);
    final flow = PassengerFlowStrings(lang);
    final scheme = Theme.of(context).colorScheme;
    final title = widget.isPassengerReporter
        ? r.screenTitlePassenger
        : r.screenTitleDriver;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: scheme.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isPassengerReporter ? r.introPassenger : r.introDriver,
              style: TextStyle(
                fontSize: 14,
                height: 1.35,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (widget.isPassengerReporter) ...[
              Text(
                r.linkTripLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (_tripsLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                DropdownButtonFormField<String?>(
                  value: _selectedTripId,
                  isExpanded: true,
                  decoration: _fieldDecoration(scheme, null),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(r.noTripSelected),
                    ),
                    ..._trips.where((t) => t.id.isNotEmpty).map((t) {
                      final line = r.tripSummaryLine(
                        flow.formatDateDayMonthYear(t.pickupDateTime),
                        t.pickupAddress.length > 24
                            ? '${t.pickupAddress.substring(0, 24)}…'
                            : t.pickupAddress,
                      );
                      return DropdownMenuItem<String?>(
                        value: t.id,
                        child: Text(
                          '$line · ${t.driverName}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: _onTripSelected,
                ),
            ] else ...[
              Text(
                r.linkJobLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<DriverProvider>(
                builder: (context, driver, _) {
                  final jobs = driver.jobs;
                  return DropdownButtonFormField<String?>(
                    value: _selectedJobId,
                    isExpanded: true,
                    decoration: _fieldDecoration(scheme, null),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(r.noTripSelected),
                      ),
                      ...jobs.map((j) {
                        final line = r.tripSummaryLine(
                          flow.formatDateDayMonthYear(j.dateTime),
                          j.pickupAddress.length > 20
                              ? '${j.pickupAddress.substring(0, 20)}…'
                              : j.pickupAddress,
                        );
                        return DropdownMenuItem<String?>(
                          value: j.id,
                          child: Text(line, overflow: TextOverflow.ellipsis),
                        );
                      }),
                    ],
                    onChanged: _onJobSelected,
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
            Text(
              widget.isPassengerReporter
                  ? r.reportedNameLabelPassenger
                  : r.reportedNameLabelDriver,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetCtrl,
              style: TextStyle(color: scheme.onSurface),
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.contentPanelColor(scheme),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              r.categoryLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ReportCategory>(
              value: _category,
              isExpanded: true,
              decoration: _fieldDecoration(scheme, null),
              items: ReportCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(r.categoryTitle(c)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 20),
            Text(
              r.detailsLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _detailsCtrl,
              maxLines: 5,
              style: TextStyle(color: scheme.onSurface),
              cursorColor: scheme.primary,
              decoration: InputDecoration(
                hintText: r.detailsHint,
                hintStyle: TextStyle(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                filled: true,
                fillColor: AppTheme.contentPanelColor(scheme),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : () => _submit(r, flow),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(r.submit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(ColorScheme scheme, String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppTheme.contentPanelColor(scheme),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }
}
