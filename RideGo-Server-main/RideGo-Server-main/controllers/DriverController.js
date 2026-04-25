import { DriverService } from '../services/DriverService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class DriverController {
  static async getDashboard(req, res) {
    try {
      const dashboard = await DriverService.getDashboard(req.userId);
      return ApiResponse.success(res, dashboard);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getRideRequests(req, res) {
    try {
      const requests = await DriverService.getRideRequests(req.userId);
      return ApiResponse.success(res, requests);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async acceptRideRequest(req, res) {
    try {
      const trip = await DriverService.acceptRideRequest(req.userId, req.params.id);
      return ApiResponse.success(res, trip, 'Ride accepted');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async declineRideRequest(req, res) {
    try {
      await DriverService.declineRideRequest(req.params.id);
      return ApiResponse.success(res, { declined: true });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async updateTripStatus(req, res) {
    try {
      const { status } = req.body;
      if (!status) return ApiResponse.error(res, 'Status is required', 400);
      const trip = await DriverService.updateTripStatus(req.userId, req.params.id, status);
      return ApiResponse.success(res, trip);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTrip(req, res) {
    try {
      const trip = await DriverService.getTrip(req.userId, req.params.id);
      if (!trip) return ApiResponse.error(res, 'Trip not found', 404);
      return ApiResponse.success(res, trip);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTripHistory(req, res) {
    try {
      const result = await DriverService.getTripHistory(req.userId, req.query);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getDocuments(req, res) {
    try {
      const documents = await DriverService.getDocuments(req.userId);
      return ApiResponse.success(res, documents);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async uploadDocument(req, res) {
    try {
      const { documentType, documentFiles, approvalStatus } = req.body;
      const document = await DriverService.uploadDocument(req.userId, {
        documentType,
        documentFiles: documentFiles || [],
        approvalStatus: approvalStatus || 'Pending',
      });
      return ApiResponse.success(res, document, 'Document uploaded', 201);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getWallet(req, res) {
    try {
      const wallet = await DriverService.getWallet(req.userId);
      return ApiResponse.success(res, wallet);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTransactions(req, res) {
    try {
      const result = await DriverService.getTransactions(req.userId, req.query);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async requestPayout(req, res) {
    try {
      const { amount } = req.body;
      if (!amount || amount <= 0) return ApiResponse.error(res, 'Valid amount is required', 400);
      const result = await DriverService.requestPayout(req.userId, amount);
      return ApiResponse.success(res, result, 'Payout requested');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
