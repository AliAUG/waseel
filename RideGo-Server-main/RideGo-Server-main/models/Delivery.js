import mongoose from 'mongoose';

const locationSchema = {
  address: { type: String, required: true },
  latitude: { type: Number },
  longitude: { type: Number },
  details: { type: String },
};

const deliverySchema = new mongoose.Schema(
  {
    customer: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
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
    packageDetails: {
      size: {
        type: String,
        enum: ['Small', 'Medium', 'Large'],
        required: true,
      },
      weightLimit: { type: String, required: true },
      specialInstructions: { type: String },
    },
    status: {
      type: String,
      enum: [
        'pending',
        'searching',
        'driver_found',
        'driver_on_the_way',
        'driver_arrived',
        'in_progress',
        'completed',
        'cancelled',
      ],
      default: 'pending',
    },
    estimatedDeliveryTimeMinutes: {
      min: { type: Number },
      max: { type: Number },
    },
    deliveryFee: { type: Number, required: true },
    distance: { type: Number },
    driverArrivalTimeEstimateMinutes: { type: Number },
    tripStartTime: { type: Date },
    tripEndTime: { type: Date },
    currency: { type: String, default: 'LBP' },
    rating: { type: mongoose.Schema.Types.ObjectId, ref: 'Rating' },
  },
  { timestamps: true }
);

deliverySchema.index({ customer: 1, createdAt: -1 });
deliverySchema.index({ driver: 1, createdAt: -1 });

export const Delivery = mongoose.model('Delivery', deliverySchema);
