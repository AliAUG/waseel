import { TripService } from '../services/TripService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class TripController {
  static async getRideTypes(req, res) {
    try {
      const rideTypes = await TripService.getRideTypes();
      return ApiResponse.success(res, rideTypes);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async createTrip(req, res) {
    try {
      const trip = await TripService.createTrip(req.userId, req.body);
      return ApiResponse.success(res, trip, 'Trip created', 201);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTrip(req, res) {
    try {
      const trip = await TripService.getTrip(req.userId, req.params.id);
      if (!trip) return ApiResponse.error(res, 'Trip not found', 404);
      return ApiResponse.success(res, trip);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTripHistory(req, res) {
    try {
      const result = await TripService.getTripHistory(req.userId, req.query);
      return ApiResponse.success(res, result);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getTripDetails(req, res) {
    try {
      const trip = await TripService.getTripDetails(req.userId, req.params.id);
      if (!trip) return ApiResponse.error(res, 'Trip not found', 404);
      return ApiResponse.success(res, trip);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async rateTrip(req, res) {
    try {
      const rating = await TripService.rateTrip(req.userId, req.params.id, req.body);
      return ApiResponse.success(res, rating, 'Rating submitted');
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
