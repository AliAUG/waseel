import mongoose from 'mongoose';

const rideTypeSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      enum: ['Economy', 'Comfort', 'Luxury'],
    },
    basePrice: { type: Number, required: true },
    timeEstimateMinutes: { type: Number },
    vehicleTypeIcon: { type: String },
    currency: { type: String, default: 'LBP' },
  },
  { timestamps: true }
);

export const RideType = mongoose.model('RideType', rideTypeSchema);
