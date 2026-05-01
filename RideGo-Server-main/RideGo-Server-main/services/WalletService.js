import { Wallet, Transaction, PaymentMethod } from '../models/index.js';

export class WalletService {
  static async getWallet(userId) {
    let wallet = await Wallet.findOne({ user: userId });
    if (!wallet) {
      wallet = await Wallet.create({ user: userId });
    }
    return wallet;
  }

  static async addBalance(userId, data) {
    const { amount, paymentMethod } = data;

    const wallet = await this.getWallet(userId);
    const newBalance = wallet.balance + amount;

    const transaction = await Transaction.create({
      user: userId,
      type: 'wallet_topup',
      amount,
      currency: wallet.currency,
      description: `Wallet top-up`,
      transactionId: `TXN-${Date.now()}`,
      paymentMethod,
    });

    wallet.balance = newBalance;
    await wallet.save();

    return {
      wallet: await this.getWallet(userId),
      transaction,
    };
  }

  static async getTransactions(userId, { page = 1, limit = 20 }) {
    const skip = (page - 1) * limit;

    const [transactions, total] = await Promise.all([
      Transaction.find({ user: userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Transaction.countDocuments({ user: userId }),
    ]);

    return { transactions, total, page, totalPages: Math.ceil(total / limit) };
  }

  static async getPaymentMethods(userId) {
    const wallet = await this.getWallet(userId);
    const methods = await PaymentMethod.find({ user: userId });

    return {
      methods,
      walletBalance: wallet.balance,
    };
  }

  static async addPaymentMethod(userId, data) {
    const { type, cardType, lastFourDigits, expiryMonth, expiryYear } = data;

    const method = await PaymentMethod.create({
      user: userId,
      type: type || 'card',
      cardType,
      lastFourDigits,
      expiryMonth,
      expiryYear,
    });

    return method;
  }

  static async setDefaultPaymentMethod(userId, methodId) {
    await PaymentMethod.updateMany({ user: userId }, { isDefault: false });
    const method = await PaymentMethod.findOneAndUpdate(
      { _id: methodId, user: userId },
      { isDefault: true },
      { new: true }
    );
    return method;
  }
}
