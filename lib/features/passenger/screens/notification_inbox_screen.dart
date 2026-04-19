import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/notification_api_service.dart';
import 'package:waseel/features/passenger/models/app_notification.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/screens/notification_settings_screen.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';

class NotificationInboxScreen extends StatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  State<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends State<NotificationInboxScreen> {
  final _api = NotificationApiService();
  final _scroll = ScrollController();

  final List<AppNotification> _rows = [];
  String _category = 'All';
  int _page = 1;
  int _totalPages = 1;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;

  static const _limit = 20;
  static const _categories = ['All', 'Jobs', 'Earnings', 'System'];

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
        category: _category,
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
      if (mounted) {
        final flow = PassengerFlowStrings(
          context.read<SettingsProvider>().language,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(flow.allMarkedReadSnack)),
        );
      }
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
    } catch (_) {
      /* ignore */
    }
  }

  void _onCategoryChanged(String cat) {
    if (cat == _category) return;
    setState(() => _category = cat);
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
          flow.notificationsTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          IconButton(
            icon: Icon(Icons.tune, color: Colors.grey.shade800),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationSettingsScreen(),
                ),
              );
            },
            tooltip: flow.notificationSettingsTooltip,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final c = _categories[i];
                      final sel = c == _category;
                      return FilterChip(
                        label: Text(flow.inboxCategoryLabel(c)),
                        selected: sel,
                        onSelected: (_) => _onCategoryChanged(c),
                        selectedColor:
                            AppTheme.primaryTeal.withValues(alpha: 0.2),
                        checkmarkColor: AppTheme.primaryTeal,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: sel
                              ? AppTheme.primaryTeal
                              : Colors.grey.shade800,
                        ),
                      );
                    },
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
                                      onPressed: () =>
                                          _loadPage(1, reset: true),
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.25,
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
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 8, 16, 24),
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
                                      return _NotificationTile(
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
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.isRead ? Colors.grey.shade200 : AppTheme.primaryTeal.withValues(alpha: 0.35),
            width: n.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                n.iconData,
                size: 22,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      color: Colors.grey.shade700,
                      height: 1.35,
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
          ],
        ),
      ),
    );
  }
}
