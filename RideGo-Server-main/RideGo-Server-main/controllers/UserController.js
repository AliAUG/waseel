import { UserService } from '../services/UserService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class UserController {
  static async updateProfile(req, res) {
    try {
      const user = await UserService.updateProfile(req.userId, req.body);
      return ApiResponse.success(res, user);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getSettings(req, res) {
    try {
      const settings = await UserService.getSettings(req.userId);
      return ApiResponse.success(res, settings);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async updateSettings(req, res) {
    try {
      const settings = await UserService.updateSettings(req.userId, req.body);
      return ApiResponse.success(res, settings);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getSavedPlaces(req, res) {
    try {
      const places = await UserService.getSavedPlaces(req.userId);
      return ApiResponse.success(res, places);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async addSavedPlace(req, res) {
    try {
      const place = await UserService.addSavedPlace(req.userId, req.body);
      return ApiResponse.success(res, place, 'Place added', 201);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async updateSavedPlace(req, res) {
    try {
      const place = await UserService.updateSavedPlace(req.userId, req.params.id, req.body);
      const message = place ? 'Place updated' : 'Place not found';
      return place ? ApiResponse.success(res, place, message) : ApiResponse.error(res, message, 404);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async deleteSavedPlace(req, res) {
    try {
      await UserService.deleteSavedPlace(req.userId, req.params.id);
      return ApiResponse.success(res, { deleted: true });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async registerPushToken(req, res) {
    try {
      const result = await UserService.registerPushToken(req.userId, req.body);
      return ApiResponse.success(res, result, 'Push token registered');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async unregisterPushToken(req, res) {
    try {
      const result = await UserService.unregisterPushToken(req.userId, req.body);
      return ApiResponse.success(res, result, 'Push token removed');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
