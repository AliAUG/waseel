import {
  Trip,
  RideType,
  Rating,
  RideRequest,
  Vehicle,
} from "../models/index.js";

export class TripService {
  static async getRideTypes() {
    return RideType.find().sort({ basePrice: 1 });
  }

  // Helper method to calculate fare breakdown
  static calculateFareBreakdown(
    basePrice,
    distanceKm = 0,
    timeMinutes = 0,
    currency = "LBP",
  ) {
    if (currency === "USD") {
      const USD_PER_KM = 1;
      const total = Math.round(distanceKm * USD_PER_KM * 100) / 100;
      return {
        baseFare: 0,
        distanceCost: total,
        distanceKm,
        timeCost: 0,
        timeMinutes,
        total,
        currency: "USD",
      };
    }

    // LBP: base + per-km + per-minute (legacy)
    const DISTANCE_RATE_PER_KM = 2500;
    const TIME_RATE_PER_MINUTE = 150;

    const distanceCost = distanceKm * DISTANCE_RATE_PER_KM;
    const timeCost = timeMinutes * TIME_RATE_PER_MINUTE;
    const total = basePrice + distanceCost + timeCost;

    return {
      baseFare: basePrice,
      distanceCost: Math.round(distanceCost),
      distanceKm,
      timeCost: Math.round(timeCost),
      timeMinutes,
      total: Math.round(total),
      currency,
    };
  }

  static async createTrip(userId, data) {
    const {
      pickupLocation,
      dropoffLocation,
      rideType,
      paymentMethod,
      distanceKm = 0,
      timeMinutes = 0,
    } = data;

    // Fetch ride type details to get base price
    const rideTypeDoc = await RideType.findById(rideType);
    if (!rideTypeDoc) throw new Error("Invalid ride type");

    const currency = data.currency || "LBP";
    const baseForFare = currency === "USD" ? 0 : rideTypeDoc.basePrice;
    const fareBreakdown = this.calculateFareBreakdown(
      baseForFare,
      distanceKm,
      timeMinutes,
      currency,
    );

    const trip = await Trip.create({
      passenger: userId,
      type: "ride",
      pickupLocation,
      dropoffLocation,
      rideType,
      paymentMethod: paymentMethod || "cash",
      status: "searching_driver",
      estimatedFare: fareBreakdown.total,
      fareBreakdown,
      currency,
    });

    await RideRequest.create({
      trip: trip._id,
      passenger: userId,
      pickupLocation,
      dropoffLocation,
      estimatedFare: fareBreakdown.total,
      type: "ride",
      status: "pending",
      expiresAt: new Date(Date.now() + 5 * 60 * 1000),
    });

    return trip.populate("rideType");
  }

  static async getTrip(userId, tripId) {
    const trip = await Trip.findOne({
      _id: tripId,
      $or: [{ passenger: userId }, { driver: userId }],
    })
      .populate("passenger", "fullName phoneNumber rating profilePicture")
      .populate("driver", "fullName phoneNumber rating profilePicture")
      .populate("rideType");

    if (!trip) return null;

    if (trip.driver) {
      const vehicle = await Vehicle.findOne({ driver: trip.driver._id }).select(
        "makeModel color plateNumber region",
      );

      trip.driver = {
        ...trip.driver.toObject(),
        vehicle,
      };
    }

    return trip;
  }

  static async getTripHistory(userId, { page = 1, limit = 20 }) {
    const skip = (page - 1) * limit;

    const [trips, total] = await Promise.all([
      Trip.find({ passenger: userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate("driver", "fullName rating")
        .populate("rideType"),
      Trip.countDocuments({ passenger: userId }),
    ]);

    return { trips, total, page, totalPages: Math.ceil(total / limit) };
  }

  static async getTripDetails(userId, tripId) {
    const trip = await Trip.findOne({
      _id: tripId,
      passenger: userId,
    })
      .populate("driver", "fullName rating profilePicture")
      .populate("rideType");

    if (!trip) return null;

    if (trip.driver) {
      const vehicle = await Vehicle.findOne({ driver: trip.driver._id }).select(
        "makeModel color plateNumber region",
      );

      trip.driver = {
        ...trip.driver.toObject(),
        vehicle,
      };
    }

    return trip;
  }

  static async rateTrip(userId, tripId, data) {
    const { stars, comment, feedbackTags } = data;

    const trip = await Trip.findOne({ _id: tripId, passenger: userId });
    if (!trip) throw new Error("Trip not found");
    if (trip.status !== "completed")
      throw new Error("Can only rate completed trips");

    const rating = await Rating.create({
      user: userId,
      driver: trip.driver,
      trip: tripId,
      stars,
      comment,
      feedbackTags,
    });

    trip.rating = rating._id;
    await trip.save();

    return rating;
  }
}
