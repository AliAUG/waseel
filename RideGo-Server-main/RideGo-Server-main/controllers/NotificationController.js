import { NotificationService } from '../services/NotificationService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class NotificationController {
  static async getNotifications(req, res) {
    try {
      const result = await NotificationService.getNotifications(req.userId, req.query);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async markAsRead(req, res) {
    try {
      const notification = await NotificationService.markAsRead(req.userId, req.params.id);
      if (!notification) return ApiResponse.error(res, 'Notification not found', 404);
      return ApiResponse.success(res, notification);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async markAllAsRead(req, res) {
    try {
      const result = await NotificationService.markAllAsRead(req.userId);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
