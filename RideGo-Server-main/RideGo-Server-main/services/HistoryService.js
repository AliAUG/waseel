import { Trip, Delivery } from '../models/index.js';

export class HistoryService {
  static async getHistory(userId, { page = 1, limit = 20, type }) {
    const skip = (page - 1) * limit;

    if (type === 'deliveries') {
      const [deliveries, total] = await Promise.all([
        Delivery.find({ customer: userId })
          .sort({ createdAt: -1 })
          .skip(skip)
          .limit(limit),
        Delivery.countDocuments({ customer: userId }),
      ]);
      return { items: deliveries, total, page, totalPages: Math.ceil(total / limit), type: 'delivery' };
    }

    const [trips, total] = await Promise.all([
      Trip.find({ passenger: userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('driver', 'fullName rating')
        .populate('rideType'),
      Trip.countDocuments({ passenger: userId }),
    ]);

    return { items: trips, total, page, totalPages: Math.ceil(total / limit), type: 'trip' };
  }

  static async getTripDetails(userId, tripId) {
    return Trip.findOne({ _id: tripId, passenger: userId })
      .populate('driver', 'fullName rating')
      .populate('rideType');
  }

  static async getDeliveryDetails(userId, deliveryId) {
    return Delivery.findOne({ _id: deliveryId, customer: userId });
  }
}
