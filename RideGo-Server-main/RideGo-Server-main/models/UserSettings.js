import mongoose from 'mongoose';

const userSettingsSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    theme: {
      type: String,
      enum: ['light', 'dark'],
      default: 'light',
    },
    language: {
      type: String,
      default: 'English',
    },
    locale: {
      type: String,
      default: 'en-LB',
    },
    region: {
      type: String,
      default: 'Lebanon',
    },
    currency: {
      type: [String],
      default: ['LBP', 'USD'],
    },
    // Ride Updates
    notifications: {
      driverAssigned: { type: Boolean, default: true },
      driverArrived: { type: Boolean, default: true },
      tripStarted: { type: Boolean, default: true },
      packagePickedUp: { type: Boolean, default: true },
      outForDelivery: { type: Boolean, default: true },
      delivered: { type: Boolean, default: true },
      promotionsAndOffers: { type: Boolean, default: true },
      systemNotifications: { type: Boolean, default: true },
      sound: { type: Boolean, default: true },
    },
    // Privacy & Safety
    privacy: {
      shareTripStatus: { type: Boolean, default: true },
      emergencyAlerts: { type: Boolean, default: true },
      hidePhoneNumber: { type: Boolean, default: false },
      showProfilePicture: { type: Boolean, default: true },
      dataCollection: { type: Boolean, default: true },
    },
    emergencyContacts: [{
      name: { type: String, required: true },
      phoneNumber: { type: String, required: true },
      relationship: { type: String },
    }],
  },
  { timestamps: true }
);

export const UserSettings = mongoose.model('UserSettings', userSettingsSchema);
