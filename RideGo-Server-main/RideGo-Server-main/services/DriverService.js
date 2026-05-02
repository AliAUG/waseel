import {
  User,
  Trip,
  Delivery,
  Vehicle,
  Document,
  DriverWallet,
  DriverTransaction,
  RideRequest,
  RideType,
} from '../models/index.js';

export class DriverService {
  static async getDashboard(userId) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const weekStart = new Date(today);
    weekStart.setDate(weekStart.getDate() - weekStart.getDay());

    const [tripsToday, tripsWeek, earningsToday, earningsWeek] = await Promise.all([
      Trip.countDocuments({ driver: userId, completedAt: { $gte: today }, status: 'completed' }),
      Trip.countDocuments({ driver: userId, completedAt: { $gte: weekStart }, status: 'completed' }),
      Trip.aggregate([
        { $match: { driver: userId, completedAt: { $gte: today }, status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$actualFare' } } },
      ]),
      Trip.aggregate([
        { $match: { driver: userId, completedAt: { $gte: weekStart }, status: 'completed' } },
        { $group: { _id: null, total: { $sum: '$actualFare' } } },
      ]),
    ]);

    const wallet = await DriverWallet.findOne({ driver: userId });
    const vehicle = await Vehicle.findOne({ driver: userId });

    return {
      earningsToday: earningsToday[0]?.total || 0,
      tripsToday,
      earningsThisWeek: earningsWeek[0]?.total || 0,
      tripsThisWeek: tripsWeek,
      balance: wallet?.balance || 0,
      currency: wallet?.currency || 'LBP',
      vehicle,
    };
  }

  static async getRideRequests(userId) {
    return RideRequest.find({
      status: 'pending',
      expiresAt: { $gt: new Date() },
    })
      .populate('passenger', 'fullName phoneNumber rating')
      .sort({ createdAt: -1 })
      .limit(10);
  }

  static async acceptRideRequest(userId, requestId) {
    const request = await RideRequest.findOne({
      _id: requestId,
      status: 'pending',
      expiresAt: { $gt: new Date() },
    });

    if (!request) throw new Error('Ride request not found or expired');

    const trip = await Trip.findByIdAndUpdate(
      request.trip,
      {
        driver: userId,
        status: 'driver_assigned',
      },
      { new: true }
    );

    request.status = 'accepted';
    await request.save();

    return trip;
  }

  static async declineRideRequest(requestId) {
    const request = await RideRequest.findByIdAndUpdate(
      requestId,
      { status: 'declined' },
      { new: true }
    );
    return request;
  }

  static async updateDriverLiveLocation(userId, tripId, latitude, longitude) {
    const trip = await Trip.findOne({ _id: tripId, driver: userId });
    if (!trip) throw new Error('Trip not found');

    const active = [
      'driver_assigned',
      'driver_en_route',
      'driver_arrived',
      'en_route',
    ];
    if (!active.includes(trip.status)) {
      throw new Error('Trip is not in an active driving state');
    }

    await Trip.findByIdAndUpdate(tripId, {
      driverLiveLocation: {
        latitude,
        longitude,
        updatedAt: new Date(),
      },
    });

    return Trip.findById(tripId)
      .populate('passenger', 'fullName phoneNumber rating profilePicture')
      .populate('rideType');
  }

  static async updateTripStatus(userId, tripId, status) {
    const trip = await Trip.findOne({ _id: tripId, driver: userId });
    if (!trip) throw new Error('Trip not found');

    const updates = { status };
    if (status === 'driver_en_route') {
      updates.estimatedArrivalMinutes = 5;
    } else if (status === 'driver_arrived') {
      // no extra fields
    } else if (status === 'en_route') {
      updates.startedAt = new Date();
    } else if (status === 'completed') {
      updates.completedAt = new Date();
      updates.actualFare = trip.estimatedFare;
    }

    await Trip.findByIdAndUpdate(tripId, updates);
    return Trip.findById(tripId).populate('passenger', 'fullName phoneNumber rating');
  }

  static async getTrip(userId, tripId) {
    const trip = await Trip.findOne({ _id: tripId, driver: userId })
      .populate('passenger', 'fullName phoneNumber rating profilePicture')
      .populate('rideType');

    // Populate vehicle details
    const driver = await User.findById(userId).select('fullName phoneNumber rating profilePicture');
    const vehicle = await Vehicle.findOne({ driver: userId });
    
    if (trip) {
      trip.driver = driver;
      trip.vehicle = vehicle;
    }
    
    return trip;
  }

  static async getTripHistory(userId, { page = 1, limit = 20 }) {
    const skip = (page - 1) * limit;

    const [trips, total] = await Promise.all([
      Trip.find({ driver: userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('passenger', 'fullName phoneNumber rating'),
      Trip.countDocuments({ driver: userId }),
    ]);

    return { trips, total, page, totalPages: Math.ceil(total / limit) };
  }

  static async getDocuments(userId) {
    return Document.find({ driver: userId });
  }

  static async uploadDocument(userId, data) {
    return Document.create({
      driver: userId,
      ...data,
    });
  }

  static async getWallet(userId) {
    let wallet = await DriverWallet.findOne({ driver: userId });
    if (!wallet) {
      wallet = await DriverWallet.create({ driver: userId });
    }
    return wallet;
  }

  static async getTransactions(userId, { page = 1, limit = 20, type = null }) {
    const skip = (page - 1) * limit;
    const query = { driver: userId };
    
    // Filter by type if provided (e.g., 'ride_payment', 'top_up', 'withdrawal')
    if (type) {
      query.type = type;
    }

    const [transactions, total] = await Promise.all([
      DriverTransaction.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      DriverTransaction.countDocuments(query),
    ]);

    return { transactions, total, page, totalPages: Math.ceil(total / limit) };
  }

  static async requestPayout(userId, amount) {
    const wallet = await this.getWallet(userId);
    if (amount > wallet.balance) throw new Error('Insufficient balance');
    if (amount < wallet.minimumWithdrawal) throw new Error(`Minimum withdrawal is ${wallet.minimumWithdrawal}`);

    const transaction = await DriverTransaction.create({
      driver: userId,
      type: 'Withdrawal',
      amount: -amount,
      status: 'Processing',
      transactionId: `PAY-${Date.now()}`,
      processingTime: 'Instant',
    });

    wallet.balance -= amount;
    await wallet.save();

    return { transaction, newBalance: wallet.balance };
  }
}
