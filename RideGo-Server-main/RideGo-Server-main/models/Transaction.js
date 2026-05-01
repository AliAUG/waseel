import mongoose from 'mongoose';

const transactionSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    type: {
      type: String,
      enum: ['trip', 'wallet_topup', 'package_delivery', 'refund', 'withdrawal', 'earning'],
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
    description: {
      type: String,
      trim: true,
    },
    transactionId: {
      type: String,
      unique: true,
      sparse: true,
    },
    paymentMethod: {
      type: String,
      trim: true,
    },
    trip: { type: mongoose.Schema.Types.ObjectId, ref: 'Trip' },
    delivery: { type: mongoose.Schema.Types.ObjectId, ref: 'Delivery' },
  },
  { timestamps: true }
);

transactionSchema.index({ user: 1, createdAt: -1 });

export const Transaction = mongoose.model('Transaction', transactionSchema);
