import mongoose from 'mongoose';

const locationSchema = {
  address: { type: String, required: true },
  latitude: { type: Number },
  longitude: { type: Number },
  details: { type: String },
};

const fareBreakdownSchema = {
  baseFare: { type: Number, default: 0 },
  distanceCost: { type: Number, default: 0 },
  distanceKm: { type: Number },
  timeCost: { type: Number, default: 0 },
  timeMinutes: { type: Number },
  total: { type: Number, required: true },
  currency: { type: String, default: 'LBP' },
};

const tripSchema = new mongoose.Schema(
  {
    passenger: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false,
    },
    type: {
      type: String,
      enum: ['ride', 'delivery'],
      required: true,
    },
    rideType: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'RideType',
      required: false,
    },
    pickupLocation: {
      type: locationSchema,
      required: true,
    },
    dropoffLocation: {
      type: locationSchema,
      required: true,
    },
    status: {
      type: String,
      enum: [
        'pending',
        'searching_driver',
        'driver_assigned',
        'driver_en_route',
        'driver_arrived',
        'en_route',
        'completed',
        'cancelled',
      ],
      default: 'pending',
    },
    estimatedFare: { type: Number },
    actualFare: { type: Number },
    fareBreakdown: fareBreakdownSchema,
    currency: { type: String, default: 'LBP' },
    estimatedArrivalMinutes: { type: Number },
    startedAt: { type: Date },
    completedAt: { type: Date },
    paymentMethod: {
      type: String,
      enum: ['cash', 'wallet', 'card'],
      default: 'cash',
    },
    rating: { type: mongoose.Schema.Types.ObjectId, ref: 'Rating' },
  },
  { timestamps: true }
);

tripSchema.index({ passenger: 1, createdAt: -1 });
tripSchema.index({ driver: 1, createdAt: -1 });
tripSchema.index({ status: 1 });

export const Trip = mongoose.model('Trip', tripSchema);
