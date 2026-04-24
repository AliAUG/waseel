import { Delivery, Rating } from '../models/index.js';
import { NotificationService } from './NotificationService.js';

export class DeliveryService {
  static async createDelivery(userId, data) {
    const { pickupLocation, dropoffLocation, packageDetails, estimatedDeliveryTimeMinutes, deliveryFee } = data;

    const delivery = await Delivery.create({
      customer: userId,
      pickupLocation,
      dropoffLocation,
      packageDetails,
      estimatedDeliveryTimeMinutes,
      deliveryFee,
      status: 'searching',
      currency: data.currency || 'LBP',
    });

    return delivery;
  }

  static async getDelivery(userId, deliveryId) {
    return Delivery.findOne({
      _id: deliveryId,
      customer: userId,
    });
  }

  static async getDeliveryHistory(userId, { page = 1, limit = 20 }) {
    const skip = (page - 1) * limit;

    const [deliveries, total] = await Promise.all([
      Delivery.find({ customer: userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Delivery.countDocuments({ customer: userId }),
    ]);

    return { deliveries, total, page, totalPages: Math.ceil(total / limit) };
  }

  static async completeDeliveryByCustomer(userId, deliveryId) {
    const delivery = await Delivery.findOne({ _id: deliveryId, customer: userId });
    if (!delivery) return null;
    if (delivery.status === 'cancelled') {
      throw new Error('Cannot complete a cancelled delivery');
    }
    if (delivery.status === 'completed') {
      return delivery;
    }
    delivery.status = 'completed';
    delivery.tripEndTime = new Date();
    await delivery.save();
    await NotificationService.createForUser(userId, {
      type: 'delivery_completed',
      category: 'Jobs',
      title: 'Delivery completed',
      message: 'Your delivery has been marked complete.',
      icon: 'package',
      details: { deliveryId: String(deliveryId) },
    });
    return delivery;
  }

  static async rateDelivery(userId, deliveryId, data) {
    const { stars, comment, feedbackTags } = data;

    const delivery = await Delivery.findOne({ _id: deliveryId, customer: userId });
    if (!delivery) throw new Error('Delivery not found');
    if (delivery.status !== 'completed') throw new Error('Can only rate completed deliveries');

    const ratingPayload = {
      user: userId,
      delivery: deliveryId,
      stars,
      comment,
      feedbackTags,
    };
    if (delivery.driver) {
      ratingPayload.driver = delivery.driver;
    }

    const rating = await Rating.create(ratingPayload);

    delivery.rating = rating._id;
    await delivery.save();

    return rating;
  }
}
