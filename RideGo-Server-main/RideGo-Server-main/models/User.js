import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
      trim: true,
    },
    phoneNumber: {
      type: String,
      trim: true,
    },
    email: {
      type: String,
      required: false,
      unique: true,
      trim: true,
      lowercase: true,
      sparse: true,
      match: /^\S+@\S+\.\S+$/,
    },
    password: {
      type: String,
      required: false,
      minlength: 6,
      select: false,
    },
    role: {
      type: String,
      enum: ['Passenger', 'Driver'],
      required: true,
    },
    isEmailVerified: {
      type: Boolean,
      default: false,
    },
    termsAndPrivacyAccepted: {
      type: Boolean,
      default: false,
    },
    profilePicture: {
      type: String,
      default: null,
    },
    // Passenger stats (from profile screen)
    tripsCount: { type: Number, default: 0 },
    deliveriesCount: { type: Number, default: 0 },
    rating: { type: Number, default: 0, min: 0, max: 5 },
    // Settings reference
    settings: { type: mongoose.Schema.Types.ObjectId, ref: 'UserSettings' },
  },
  { timestamps: true }
);

userSchema.pre('save', async function (next) {
  if (this.isModified('password') && this.password) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

export const User = mongoose.model('User', userSchema);
