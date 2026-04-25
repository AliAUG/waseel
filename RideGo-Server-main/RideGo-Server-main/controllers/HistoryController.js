import { HistoryService } from '../services/HistoryService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class HistoryController {
  static async getHistory(req, res) {
    try {
      const result = await HistoryService.getHistory(req.userId, req.query);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTripDetails(req, res) {
    try {
      const trip = await HistoryService.getTripDetails(req.userId, req.params.id);
      if (!trip) return ApiResponse.error(res, 'Trip not found', 404);
      return ApiResponse.success(res, trip);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getDeliveryDetails(req, res) {
    try {
      const delivery = await HistoryService.getDeliveryDetails(req.userId, req.params.id);
      if (!delivery) return ApiResponse.error(res, 'Delivery not found', 404);
      return ApiResponse.success(res, delivery);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
