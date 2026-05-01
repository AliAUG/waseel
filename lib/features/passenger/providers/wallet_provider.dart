import 'package:flutter/foundation.dart';
import 'package:waseel/features/passenger/data/wallet_api_service.dart';
import 'package:waseel/features/passenger/models/payment_method.dart';
import 'package:waseel/features/passenger/models/wallet_transaction.dart';

class WalletProvider extends ChangeNotifier {
  WalletProvider({WalletApiService? walletApi})
      : _walletApi = walletApi ?? WalletApiService() {
    _initDemoData();
  }

  final WalletApiService _walletApi;

  int _balance = 425000; // Demo until [syncBalanceFromBackend] with a real token
  final List<WalletTransaction> _transactions = [];
  final List<PaymentMethod> _paymentMethods = [];
  String? _selectedPaymentMethodId;
  String? _defaultPaymentMethodId;
  TopUpResult? _lastTopUp;

  bool _balanceLoading = false;
  String? _balanceSyncError;

  bool get balanceLoading => _balanceLoading;
  String? get balanceSyncError => _balanceSyncError;

  bool _isRealToken(String? token) =>
      token != null &&
      token.isNotEmpty &&
      token != 'local-session';

  /// `GET /wallet` + `GET /wallet/transactions` — balance + recent list (real token only).
  Future<void> syncBalanceFromBackend(String? token) async {
    if (!_isRealToken(token)) {
      _balanceSyncError = null;
      return;
    }

    _balanceLoading = true;
    _balanceSyncError = null;
    notifyListeners();

    try {
      final walletData = await _walletApi.getWallet(token!);
      final rawBal = walletData['balance'];
      if (rawBal != null) {
        if (rawBal is int) {
          _balance = rawBal;
        } else if (rawBal is double) {
          _balance = rawBal.round();
        } else {
          _balance = int.tryParse(rawBal.toString()) ?? _balance;
        }
      }

      final txMaps = await _walletApi.getTransactions(token, page: 1, limit: 30);
      _transactions
        ..clear()
        ..addAll(txMaps.map(WalletTransaction.fromBackend));
      _transactions.sort((a, b) => b.date.compareTo(a.date));

      _paymentMethods.clear();
      _defaultPaymentMethodId = null;
      _selectedPaymentMethodId = null;
      try {
        final pmPayload = await _walletApi.getPaymentMethods(token);
        _applyPaymentMethodsPayload(pmPayload);
      } catch (_) {
        // Stay with empty card list if this endpoint fails.
      }
    } catch (e) {
      _balanceSyncError = e.toString();
    } finally {
      _balanceLoading = false;
      notifyListeners();
    }
  }

  void _initDemoData() {
    final now = DateTime.now();
    _transactions.addAll([
      WalletTransaction(
        id: '1',
        type: TransactionType.trip,
        description: 'Trip to Business Bay',
        date: DateTime(now.year, now.month, now.day - 1, 14, 30),
        amount: -42000,
      ),
      WalletTransaction(
        id: '2',
        type: TransactionType.topUp,
        description: 'Wallet Top-up',
        date: DateTime(now.year, now.month, now.day - 2, 11, 20),
        amount: 100000,
      ),
      WalletTransaction(
        id: '3',
        type: TransactionType.delivery,
        description: 'Package Delivery',
        date: DateTime(now.year, now.month, now.day - 2, 9, 15),
        amount: -22500,
      ),
      WalletTransaction(
        id: '4',
        type: TransactionType.trip,
        description: 'Trip to Airport',
        date: DateTime(now.year, now.month, now.day - 3, 9, 0),
        amount: -67500,
      ),
      WalletTransaction(
        id: '5',
        type: TransactionType.refund,
        description: 'Refund',
        date: DateTime(now.year, now.month, now.day - 4, 18, 0),
        amount: 18000,
      ),
    ]);
    _transactions.sort((a, b) => b.date.compareTo(a.date));

    _paymentMethods.addAll([
      const PaymentMethod(
        id: 'pm1',
        type: 'Visa',
        lastFour: '4242',
        expiryMonth: 12,
        expiryYear: 25,
        isDefault: true,
      ),
      const PaymentMethod(
        id: 'pm2',
        type: 'Mastercard',
        lastFour: '5555',
        expiryMonth: 12,
        expiryYear: 25,
      ),
    ]);
    _selectedPaymentMethodId = _paymentMethods.first.id;
    _defaultPaymentMethodId = _paymentMethods.first.id;
  }

  int get balance => _balance;
  String? get defaultPaymentMethodId => _defaultPaymentMethodId;
  TopUpResult? get lastTopUp => _lastTopUp;
  PaymentMethod? get defaultPaymentMethod =>
      _paymentMethods.cast<PaymentMethod?>().firstWhere(
            (p) => p?.id == _defaultPaymentMethodId,
            orElse: () => null,
          );

  void _applyPaymentMethodsPayload(Map<String, dynamic> data) {
    _paymentMethods.clear();
    final raw = data['methods'];
    if (raw is List) {
      for (final e in raw) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        if (m['type']?.toString() != 'card') continue;
        try {
          _paymentMethods.add(PaymentMethod.fromBackend(m));
        } catch (_) {
          continue;
        }
      }
    }
    PaymentMethod? def;
    for (final p in _paymentMethods) {
      if (p.isDefault) {
        def = p;
        break;
      }
    }
    _defaultPaymentMethodId = def?.id ??
        (_paymentMethods.isNotEmpty ? _paymentMethods.first.id : null);
    final sel = _selectedPaymentMethodId;
    if (sel == null || !_paymentMethods.any((p) => p.id == sel)) {
      _selectedPaymentMethodId = _defaultPaymentMethodId;
    }
  }

  /// `POST /wallet/payment-methods` then refetches card list.
  Future<void> addCardPaymentMethod(
    String token, {
    required String cardType,
    required String lastFourDigits,
    required int expiryMonth,
    required int expiryYear,
  }) async {
    await _walletApi.addPaymentMethod(
      token,
      cardType: cardType,
      lastFourDigits: lastFourDigits,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
    );
    final payload = await _walletApi.getPaymentMethods(token);
    _applyPaymentMethodsPayload(payload);
    notifyListeners();
  }

  /// Local demo: sets default only. Logged-in: `PUT` then refetches methods.
  Future<void> setDefaultPaymentMethod(String id, {String? authToken}) async {
    if (!_isRealToken(authToken)) {
      _defaultPaymentMethodId = id;
      notifyListeners();
      return;
    }
    await _walletApi.setDefaultPaymentMethod(authToken!, id);
    final payload = await _walletApi.getPaymentMethods(authToken);
    _applyPaymentMethodsPayload(payload);
    notifyListeners();
  }
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);
  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);
  String? get selectedPaymentMethodId => _selectedPaymentMethodId;
  PaymentMethod? get selectedPaymentMethod =>
      _paymentMethods.cast<PaymentMethod?>().firstWhere(
            (p) => p?.id == _selectedPaymentMethodId,
            orElse: () => null,
          );

  void selectPaymentMethod(String id) {
    _selectedPaymentMethodId = id;
    notifyListeners();
  }

  /// `POST /wallet/add-balance` then updates balance + prepends the new transaction.
  Future<TopUpResult> topUpAuthenticated(
    String token,
    int amount,
    PaymentMethod? paymentMethod,
  ) async {
    final pmLabel = paymentMethod != null
        ? '${paymentMethod.type} •••• ${paymentMethod.lastFour}'
        : null;
    final data = await _walletApi.addBalance(
      token,
      amount: amount,
      paymentMethod: pmLabel,
    );

    final walletMap = data['wallet'];
    if (walletMap is! Map) {
      throw StateError('Invalid wallet response after top-up');
    }
    final w = Map<String, dynamic>.from(walletMap);
    final rawBal = w['balance'];
    if (rawBal != null) {
      if (rawBal is int) {
        _balance = rawBal;
      } else if (rawBal is double) {
        _balance = rawBal.round();
      } else {
        _balance = int.tryParse(rawBal.toString()) ?? _balance;
      }
    }

    final txMap = data['transaction'];
    String txnIdForUi = '';
    var txnDate = DateTime.now();
    if (txMap is Map) {
      final m = Map<String, dynamic>.from(txMap);
      txnIdForUi = m['transactionId']?.toString() ?? '';
      final wt = WalletTransaction.fromBackend(m);
      if (txnIdForUi.isEmpty) txnIdForUi = wt.id;
      txnDate = wt.date;
      if (wt.id.isNotEmpty) {
        _transactions.removeWhere((t) => t.id == wt.id);
      }
      _transactions.insert(0, wt);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    }

    _lastTopUp = TopUpResult(
      amount: amount,
      newBalance: _balance,
      transactionId: txnIdForUi.isEmpty ? '—' : txnIdForUi,
      paymentMethod: paymentMethod ??
          const PaymentMethod(
            id: '-',
            type: 'Wallet',
            lastFour: '—',
            expiryMonth: 1,
            expiryYear: 99,
          ),
      dateTime: txnDate,
    );
    notifyListeners();
    return _lastTopUp!;
  }

  /// Resets to demo wallet state after [AuthProvider.logout].
  void resetForLogout() {
    _transactions.clear();
    _paymentMethods.clear();
    _selectedPaymentMethodId = null;
    _defaultPaymentMethodId = null;
    _lastTopUp = null;
    _balanceSyncError = null;
    _balanceLoading = false;
    _balance = 425000;
    _initDemoData();
    notifyListeners();
  }

  TopUpResult topUp(int amount) {
    _balance += amount;
    final now = DateTime.now();
    final txnId = 'TXN-${(now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';
    _transactions.insert(
      0,
      WalletTransaction(
        id: txnId,
        type: TransactionType.topUp,
        description: 'Wallet Top-up',
        date: now,
        amount: amount,
      ),
    );
    _lastTopUp = TopUpResult(
      amount: amount,
      newBalance: _balance,
      transactionId: txnId,
      paymentMethod: selectedPaymentMethod!,
      dateTime: now,
    );
    notifyListeners();
    return _lastTopUp!;
  }
}

class TopUpResult {
  const TopUpResult({
    required this.amount,
    required this.newBalance,
    required this.transactionId,
    required this.paymentMethod,
    required this.dateTime,
  });

  final int amount;
  final int newBalance;
  final String transactionId;
  final PaymentMethod paymentMethod;
  final DateTime dateTime;
}
