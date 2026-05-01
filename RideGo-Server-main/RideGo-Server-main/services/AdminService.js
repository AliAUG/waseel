import { Trip } from '../models/Trip.js';
import { User } from '../models/User.js';


export class AdminService {
  static async createTrip(data) {
    const trip = await Trip.create(data);
    return { success: true, data: trip };
  }

  static async getTrips(query) {
    const { page = 1, pageSize = 10, status, type } = query;

    const filter = {};
    if (status) filter.status = status;
    if (type) filter.type = type;

    const trips = await Trip.find(filter)
      .populate('passenger', 'firstName lastName phoneNumber')
      .populate('driver', 'firstName lastName')
      .populate('rideType', 'name')
      .sort({ createdAt: -1 })
      .skip((page - 1) * pageSize)
      .limit(Number(pageSize));

    const total = await Trip.countDocuments(filter);

    return {
      success: true,
      data: trips,
      page: Number(page),
      pageSize: Number(pageSize),
      total,
    };
  }

  static async getTripById(id) {
    const trip = await Trip.findById(id)
      .populate('passenger driver rideType');

    if (!trip) throw new Error('Trip not found');

    return { success: true, data: trip };
  }

  static async updateTrip(id, data) {
    const trip = await Trip.findByIdAndUpdate(id, data, { new: true });

    if (!trip) throw new Error('Trip not found');

    return { success: true, data: trip };
  }

  static async deleteTrip(id) {
    const trip = await Trip.findByIdAndDelete(id);

    if (!trip) throw new Error('Trip not found');

    return { success: true, message: 'Trip deleted' };
  }

  static async updateStatus(id, status) {
    const trip = await Trip.findByIdAndUpdate(
      id,
      { status },
      { new: true }
    );

    if (!trip) throw new Error('Trip not found');

    return { success: true, data: trip };
  }

  static async assignDriver(id, driverId) {
    const trip = await Trip.findByIdAndUpdate(
      id,
      {
        driver: driverId,
        status: 'driver_assigned',
      },
      { new: true }
    );

    if (!trip) throw new Error('Trip not found');

    return { success: true, data: trip };
  }

  static async getPassengers() {
    const users = await User.find({ role: 'Passenger' })
      .select('_id fullName email phoneNumber');

    return {
      success: true,
      data: users,
    };
  }

  static async getDrivers() {
    const drivers = await User.find({ role: 'Driver' })
      .select('_id fullName email phoneNumber');

    return {
      success: true,
      data: drivers,
    };
  }
}