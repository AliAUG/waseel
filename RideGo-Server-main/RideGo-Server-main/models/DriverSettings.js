import mongoose from 'mongoose';

const driverSettingsSchema = new mongoose.Schema(
  {
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    language: {
      type: String,
      default: 'English',
    },
    notifications: {
      jobAlertsEnabled: { type: Boolean, default: true },
      promotionsEnabled: { type: Boolean, default: true },
      systemMessagesEnabled: { type: Boolean, default: true },
      soundAlertsEnabled: { type: Boolean, default: true },
    },
  },
  { timestamps: true }
);

export const DriverSettings = mongoose.model('DriverSettings', driverSettingsSchema);
