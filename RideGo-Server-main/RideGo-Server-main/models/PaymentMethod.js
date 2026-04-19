import mongoose from 'mongoose';

const paymentMethodSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    type: {
      type: String,
      enum: ['card', 'wallet', 'cash'],
      required: true,
    },
    // For card payments
    cardType: { type: String, enum: ['Visa', 'Mastercard', 'Other'] },
    lastFourDigits: { type: String, maxlength: 4 },
    expiryMonth: { type: Number, min: 1, max: 12 },
    expiryYear: { type: Number },
    isDefault: {
      type: Boolean,
      default: false,
    },
    // For wallet - balance shown in Payment Methods screen
    walletBalance: { type: Number },
  },
  { timestamps: true }
);

paymentMethodSchema.index({ user: 1 });

export const PaymentMethod = mongoose.model('PaymentMethod', paymentMethodSchema);
