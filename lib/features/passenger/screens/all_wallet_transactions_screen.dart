import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waseel/core/network/api_exception.dart';
import 'package:waseel/core/theme.dart';
import 'package:waseel/features/auth/providers/auth_provider.dart';
import 'package:waseel/features/passenger/data/wallet_api_service.dart';
import 'package:waseel/features/passenger/models/wallet_transaction.dart';
import 'package:waseel/features/passenger/providers/settings_provider.dart';
import 'package:waseel/features/passenger/providers/wallet_provider.dart';
import 'package:waseel/features/passenger/strings/passenger_flow_strings.dart';
import 'package:waseel/features/passenger/widgets/wallet_transaction_tile.dart';

class AllWalletTransactionsScreen extends StatefulWidget {
  const AllWalletTransactionsScreen({super.key});

  @override
  State<AllWalletTransactionsScreen> createState() =>
      _AllWalletTransactionsScreenState();
}

class _AllWalletTransactionsScreenState
    extends State<AllWalletTransactionsScreen> {
  final _api = WalletApiService();
  final _scroll = ScrollController();

  final List<WalletTransaction> _rows = [];
  int _page = 1;
  int _totalPages = 1;
  bool _initialLoading = true;
  bool _loadingMore = false;
  String? _error;

  static const _limit = 20;

  bool _isRealToken(String? t) =>
      t != null && t.isNotEmpty && t != 'local-session';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
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
      _loadPage(_page + 1, append: true);
    }
  }

  Future<void> _bootstrap() async {
    final token = context.read<AuthProvider>().token;
    if (!_isRealToken(token)) {
      setState(() {
        _rows
          ..clear()
          ..addAll(context.read<WalletProvider>().transactions);
        _initialLoading = false;
        _totalPages = 1;
      });
      return;
    }
    await _loadPage(1, append: false);
  }

  Future<void> _loadPage(int page, {required bool append}) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty || token == 'local-session') {
      return;
    }

    if (append) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _initialLoading = true;
        _error = null;
      });
    }

    try {
      final r = await _api.getTransactionsWithMeta(
        token,
        page: page,
        limit: _limit,
      );
      final mapped =
          r.items.map(WalletTransaction.fromBackend).toList();
      if (!mounted) return;
      setState(() {
        if (append) {
          _rows.addAll(mapped);
        } else {
          _rows
            ..clear()
            ..addAll(mapped);
        }
        _page = r.page;
        _totalPages = r.totalPages < 1 ? 1 : r.totalPages;
        _error = null;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
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
    final token = context.read<AuthProvider>().token;
    if (!_isRealToken(token)) {
      setState(() {
        _rows
          ..clear()
          ..addAll(context.read<WalletProvider>().transactions);
      });
      return;
    }
    await _loadPage(1, append: false);
  }

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
          flow.walletAllTransactionsTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
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
                          onPressed: () => _loadPage(1, append: false),
                          child: Text(
                            flow.retry,
                            style: const TextStyle(color: AppTheme.primaryTeal),
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
                            height: MediaQuery.sizeOf(context).height * 0.3,
                          ),
                          Center(
                            child: Text(
                              flow.noTransactionsYet,
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
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: _rows.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= _rows.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
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
                          return WalletTransactionTile(
                            transaction: _rows[i],
                          );
                        },
                      ),
      ),
    );
  }
}
