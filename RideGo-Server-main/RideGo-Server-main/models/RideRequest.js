import mongoose from 'mongoose';

/**
 * Represents an incoming ride/delivery request shown to drivers
 * (e.g. "New Ride Request" with 20s countdown to accept)
 */
const rideRequestSchema = new mongoose.Schema(
  {
    trip: { type: mongoose.Schema.Types.ObjectId, ref: 'Trip' },
    delivery: { type: mongoose.Schema.Types.ObjectId, ref: 'Delivery' },
    passenger: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    pickupLocation: {
      address: { type: String, required: true },
      latitude: { type: Number },
      longitude: { type: Number },
    },
    dropoffLocation: {
      address: { type: String, required: true },
      latitude: { type: Number },
      longitude: { type: Number },
    },
    estimatedFare: { type: Number, required: true },
    currency: { type: String, default: 'LBP' },
    type: {
      type: String,
      enum: ['ride', 'delivery'],
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'declined', 'expired'],
      default: 'pending',
    },
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true }
);

rideRequestSchema.index({ status: 1, expiresAt: 1 });

export const RideRequest = mongoose.model('RideRequest', rideRequestSchema);
