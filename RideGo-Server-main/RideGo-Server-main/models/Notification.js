import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    type: {
      type: String,
      required: true,
      enum: [
        'new_ride_request',
        'document_approved',
        'weekly_earnings_summary',
        'delivery_completed',
        'bonus_campaign',
        'driver_assigned',
        'driver_arrived',
        'trip_started',
        'trip_completed',
      ],
    },
    category: {
      type: String,
      enum: ['Jobs', 'Earnings', 'System'],
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    icon: {
      type: String,
      enum: ['car', 'document', 'money', 'package'],
    },
    isRead: {
      type: Boolean,
      default: false,
    },
    details: {
      type: mongoose.Schema.Types.Mixed,
    },
  },
  { timestamps: true }
);

notificationSchema.index({ user: 1, createdAt: -1 });
notificationSchema.index({ user: 1, isRead: 1 });

export const Notification = mongoose.model('Notification', notificationSchema);
