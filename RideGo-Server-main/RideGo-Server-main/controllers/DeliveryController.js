import { DeliveryService } from '../services/DeliveryService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class DeliveryController {
  static async createDelivery(req, res) {
    try {
      const delivery = await DeliveryService.createDelivery(req.userId, req.body);
      return ApiResponse.success(res, delivery, 'Delivery requested', 201);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getDelivery(req, res) {
    try {
      const delivery = await DeliveryService.getDelivery(req.userId, req.params.id);
      if (!delivery) return ApiResponse.error(res, 'Delivery not found', 404);
      return ApiResponse.success(res, delivery);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getDeliveryHistory(req, res) {
    try {
      const result = await DeliveryService.getDeliveryHistory(req.userId, req.query);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  /// `POST /deliveries/complete` body: `{ deliveryId }` — avoids fragile `/:id/complete` routing.
  static async completeDeliveryByBody(req, res) {
    try {
      const deliveryId = req.body?.deliveryId;
      if (!deliveryId) {
        return ApiResponse.error(res, 'deliveryId is required', 400);
      }
      const delivery = await DeliveryService.completeDeliveryByCustomer(
        req.userId,
        deliveryId,
      );
      if (!delivery) return ApiResponse.error(res, 'Delivery not found', 404);
      return ApiResponse.success(res, delivery, 'Delivery completed');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async rateDelivery(req, res) {
    try {
      const rating = await DeliveryService.rateDelivery(req.userId, req.params.id, req.body);
      return ApiResponse.success(res, rating, 'Rating submitted');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
