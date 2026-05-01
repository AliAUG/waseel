import { WalletService } from '../services/WalletService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class WalletController {
  static async getWallet(req, res) {
    try {
      const wallet = await WalletService.getWallet(req.userId);
      return ApiResponse.success(res, wallet);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async addBalance(req, res) {
    try {
      const { amount, paymentMethod } = req.body;
      if (!amount || amount <= 0) {
        return ApiResponse.error(res, 'Valid amount is required', 400);
      }
      const result = await WalletService.addBalance(req.userId, { amount, paymentMethod });
      return ApiResponse.success(res, result, 'Balance added');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTransactions(req, res) {
    try {
      const result = await WalletService.getTransactions(req.userId, req.query);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getPaymentMethods(req, res) {
    try {
      const result = await WalletService.getPaymentMethods(req.userId);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async addPaymentMethod(req, res) {
    try {
      const method = await WalletService.addPaymentMethod(req.userId, req.body);
      return ApiResponse.success(res, method, 'Payment method added', 201);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async setDefaultPaymentMethod(req, res) {
    try {
      const method = await WalletService.setDefaultPaymentMethod(req.userId, req.params.id);
      if (!method) return ApiResponse.error(res, 'Payment method not found', 404);
      return ApiResponse.success(res, method);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
