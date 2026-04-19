import mongoose from 'mongoose';

const driverTransactionSchema = new mongoose.Schema(
  {
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    type: {
      type: String,
      enum: ['Earning', 'Withdrawal', 'Bonus', 'Penalty'],
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      default: 'LBP',
    },
    status: {
      type: String,
      enum: ['Completed', 'Pending', 'Failed', 'Processing'],
      default: 'Completed',
    },
    description: { type: String },
    relatedTrip: { type: mongoose.Schema.Types.ObjectId, ref: 'Trip' },
    relatedDelivery: { type: mongoose.Schema.Types.ObjectId, ref: 'Delivery' },
    transactionId: { type: String },
    processingTime: { type: String },
    processingFee: { type: Number, default: 0 },
  },
  { timestamps: true }
);

driverTransactionSchema.index({ driver: 1, createdAt: -1 });

export const DriverTransaction = mongoose.model('DriverTransaction', driverTransactionSchema);
