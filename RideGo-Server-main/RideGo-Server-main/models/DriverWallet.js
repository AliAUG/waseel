import mongoose from 'mongoose';

const driverWalletSchema = new mongoose.Schema(
  {
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    balance: {
      type: Number,
      default: 0,
      min: 0,
    },
    currency: {
      type: String,
      default: 'LBP',
    },
    payoutMethod: {
      type: {
        type: String,
        enum: ['Wish Money', 'Bank Transfer', 'Other'],
        default: 'Wish Money',
      },
      details: { type: String },
    },
    minimumWithdrawal: {
      type: Number,
      default: 75000,
    },
  },
  { timestamps: true }
);

export const DriverWallet = mongoose.model('DriverWallet', driverWalletSchema);
