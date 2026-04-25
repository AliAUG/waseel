import mongoose from 'mongoose';

const verificationCodeSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: false,
    },
    phoneNumber: {
      type: String,
      required: function () {
        return !this.email;
      },
      trim: true,
    },
    email: {
      type: String,
      required: function () {
        return !this.phoneNumber;
      },
      trim: true,
      lowercase: true,
    },
    code: {
      type: String,
      required: true,
      minlength: 6,
      maxlength: 6,
    },
    type: {
      type: String,
      enum: ['account_creation', 'login', 'password_reset', 'email_verification'],
      required: true,
    },
    expiresAt: {
      type: Date,
      required: true,
    },
    isUsed: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

// TTL index - documents auto-delete after expiresAt
verificationCodeSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export const VerificationCode = mongoose.model('VerificationCode', verificationCodeSchema);
