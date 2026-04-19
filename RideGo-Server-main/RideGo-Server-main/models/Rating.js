import mongoose from 'mongoose';

const ratingSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false,
    },
    trip: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Trip',
      required: false,
    },
    delivery: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Delivery',
      required: false,
    },
    stars: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    comment: {
      type: String,
      trim: true,
    },
    feedbackTags: [{
      type: String,
      trim: true,
      enum: ['Friendly driver', 'Clean car', 'Safe driving', 'On time', 'Good music'],
    }],
  },
  { timestamps: true }
);

ratingSchema.index({ driver: 1 });
ratingSchema.index({ trip: 1 }, { sparse: true });
ratingSchema.index({ delivery: 1 }, { sparse: true });

export const Rating = mongoose.model('Rating', ratingSchema);
