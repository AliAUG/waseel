import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/notification_api_service.dart';
import 'package:waseel/features/passenger/models/app_notification.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

enum DriverNotificationFilter { all, jobs, earnings, system }

class DriverNotificationsScreen extends StatefulWidget {
  const DriverNotificationsScreen({super.key});

  @override
  State<DriverNotificationsScreen> createState() =>
      _DriverNotificationsScreenState();
}

class _DriverNotificationsScreenState extends State<DriverNotificationsScreen> {
  final _api = NotificationApiService();
  final _scroll = ScrollController();

  DriverNotificationFilter _filter = DriverNotificationFilter.all;
  final List<AppNotification> _rows = [];
  int _page = 1;
  int _totalPages = 1;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;

  static const _limit = 20;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPage(1, reset: true));
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  String _categoryQuery() {
    switch (_filter) {
      case DriverNotificationFilter.all:
        return 'All';
      case DriverNotificationFilter.jobs:
        return 'Jobs';
      case DriverNotificationFilter.earnings:
        return 'Earnings';
      case DriverNotificationFilter.system:
        return 'System';
    }
  }

  void _onScroll() {
    if (_loadingMore || _initialLoading || _error != null) return;
    if (_page >= _totalPages) return;
    final pos = _scroll.position;
    if (!pos.hasPixels || !pos.hasContentDimensions) return;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadPage(_page + 1, reset: false);
    }
  }

  bool _isRealToken(String? t) =>
      t != null && t.isNotEmpty && t != 'local-session';

  Future<void> _loadPage(int page, {required bool reset}) async {
    final token = context.read<AuthProvider>().token;
    if (!_isRealToken(token)) {
      setState(() {
        _initialLoading = false;
        _rows.clear();
        _error = null;
      });
      return;
    }

    if (reset) {
      setState(() {
        _initialLoading = true;
        _error = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final r = await _api.getNotifications(
        token!,
        page: page,
        limit: _limit,
        category: _categoryQuery(),
      );
      final mapped = r.items.map(AppNotification.fromBackend).toList();
      if (!mounted) return;
      setState(() {
        if (reset) {
          _rows
            ..clear()
            ..addAll(mapped);
        } else {
          _rows.addAll(mapped);
        }
        _page = r.page;
        _totalPages = r.totalPages < 1 ? 1 : r.totalPages;
        _error = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _initialLoading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadPage(1, reset: true);
  }

  Future<void> _markAllRead() async {
    final token = context.read<AuthProvider>().token;
    if (!_isRealToken(token)) return;
    try {
      await _api.markAllAsRead(token!);
      if (!mounted) return;
      await _loadPage(1, reset: true);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _onTapNotification(AppNotification n) async {
    final token = context.read<AuthProvider>().token;
    if (!_isRealToken(token) || n.isRead) return;
    try {
      await _api.markAsRead(token!, n.id);
      if (!mounted) return;
      setState(() {
        final i = _rows.indexWhere((x) => x.id == n.id);
        if (i >= 0) {
          _rows[i] = n.copyWith(isRead: true);
        }
      });
    } catch (_) {}
  }

  void _onFilterSelected(DriverNotificationFilter f) {
    if (f == _filter) return;
    setState(() => _filter = f);
    _loadPage(1, reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final flow = PassengerFlowStrings(context.watch<SettingsProvider>().language);
    final token = context.watch<AuthProvider>().token;
    final loggedIn = _isRealToken(token);

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
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
        actions: [
          if (loggedIn)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                flow.readAllNotifications,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
        ],
      ),
      body: !loggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  flow.signInForNotifications,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: DriverNotificationFilter.values.map((f) {
                        final isSelected = _filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(_filterLabel(f)),
                            selected: isSelected,
                            onSelected: (_) => _onFilterSelected(f),
                            selectedColor: AppTheme.primaryTeal,
                            checkmarkColor: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: _initialLoading
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
                                  const SizedBox(height: 80),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: TextButton(
                                      onPressed: () => _loadPage(1, reset: true),
                                      child: Text(
                                        flow.retry,
                                        style: const TextStyle(
                                          color: AppTheme.primaryTeal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _rows.isEmpty
                                ? ListView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.2,
                                      ),
                                      Center(
                                        child: Text(
                                          flow.noNotifications,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : ListView.builder(
                                    controller: _scroll,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 8, 20, 24),
                                    itemCount:
                                        _rows.length + (_loadingMore ? 1 : 0),
                                    itemBuilder: (context, i) {
                                      if (i >= _rows.length) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      final n = _rows[i];
                                      return _DriverNotificationTile(
                                        notification: n,
                                        flow: flow,
                                        onTap: () => _onTapNotification(n),
                                      );
                                    },
                                  ),
                  ),
                ),
              ],
            ),
    );
  }

  String _filterLabel(DriverNotificationFilter f) {
    switch (f) {
      case DriverNotificationFilter.all:
        return 'All';
      case DriverNotificationFilter.jobs:
        return 'Jobs';
      case DriverNotificationFilter.earnings:
        return 'Earnings';
      case DriverNotificationFilter.system:
        return 'System';
    }
  }
}

class _DriverNotificationTile extends StatelessWidget {
  const _DriverNotificationTile({
    required this.notification,
    required this.flow,
    required this.onTap,
  });

  final AppNotification notification;
  final PassengerFlowStrings flow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.isRead
                ? Colors.grey.shade200
                : AppTheme.primaryTeal.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(n.iconData, color: AppTheme.primaryTeal, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                n.isRead ? FontWeight.w600 : FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                      Text(
                        flow.formatDateDayMonth(n.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
