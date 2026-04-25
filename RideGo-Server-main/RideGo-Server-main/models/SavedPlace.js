import mongoose from 'mongoose';

const savedPlaceSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    label: {
      type: String,
      required: true,
      trim: true,
    },
    address: {
      type: String,
      required: true,
      trim: true,
    },
    latitude: { type: Number },
    longitude: { type: Number },
    order: { type: Number, default: 0 },
  },
  { timestamps: true }
);

savedPlaceSchema.index({ user: 1 });

export const SavedPlace = mongoose.model('SavedPlace', savedPlaceSchema);
