import mongoose from 'mongoose';

const vehicleSchema = new mongoose.Schema(
  {
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    makeModel: {
      type: String,
      required: true,
      trim: true,
    },
    year: {
      type: Number,
      required: true,
    },
    color: {
      type: String,
      required: true,
      trim: true,
    },
    plateNumber: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    region: {
      type: String,
      trim: true,
    },
    active: {
      type: Boolean,
      default: true,
    },
  },
  { timestamps: true }
);

vehicleSchema.index({ driver: 1 });

export const Vehicle = mongoose.model('Vehicle', vehicleSchema);
