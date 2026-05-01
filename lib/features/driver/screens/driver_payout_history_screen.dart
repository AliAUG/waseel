import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/driver/data/driver_api_service.dart';
import 'package:waseel/features/driver/strings/driver_ui_strings.dart';
import 'package:waseel/features/passenger/models/package_size.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class DriverPayoutHistoryScreen extends StatefulWidget {
  const DriverPayoutHistoryScreen({super.key});

  @override
  State<DriverPayoutHistoryScreen> createState() =>
      _DriverPayoutHistoryScreenState();
}

class _DriverPayoutHistoryScreenState extends State<DriverPayoutHistoryScreen> {
  bool _loading = true;
  String? _error;
  bool _noSession = false;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _noSession = false;
    });
    final auth = context.read<AuthProvider>();
    final t = auth.token;
    if (t == null || t.isEmpty || t == 'local-session') {
      if (mounted) {
        setState(() {
          _loading = false;
          _noSession = true;
          _items = [];
        });
      }
      return;
    }
    try {
      final m = await DriverApiService().getTransactions(
        t,
        page: 1,
        limit: 50,
        type: 'Withdrawal',
      );
      final raw = m['transactions'];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) {
            list.add(Map<String, dynamic>.from(e));
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _items = list;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'load';
      });
    }
  }

  static int _amount(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    return int.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _createdAt(Map<String, dynamic> m) {
    final s = m['createdAt']?.toString();
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  @override
  Widget build(BuildContext context) {
    final d = DriverUiStrings(context.watch<SettingsProvider>().language);
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
          d.payoutHistoryScreenTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 48),
                      Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        d.payoutHistoryLoadError,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  )
                : _noSession
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 48),
                          Text(
                            d.payoutHistoryNeedLogin,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                        ],
                      )
                    : _items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 80),
                              Icon(Icons.payments_outlined,
                                  size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                d.payoutHistoryEmpty,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final m = _items[i];
                              final amt = _amount(m['amount']).abs();
                              final status =
                                  m['status']?.toString() ?? '—';
                              final tid =
                                  m['transactionId']?.toString() ?? '—';
                              final dt = _createdAt(m);
                              final dateStr = dt != null
                                  ? flow.formatDateMonthCommaDayYear(dt)
                                  : '—';
                              final timeStr = dt != null
                                  ? flow.formatTime12hAmPm(dt)
                                  : '';

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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatLebanesePounds(amt),
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryTeal
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            status,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryTeal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$dateStr${timeStr.isNotEmpty ? ', $timeStr' : ''}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${d.transactionIdLabel}: $tid',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
      ),
    );
  }
}
