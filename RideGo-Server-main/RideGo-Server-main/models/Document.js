import mongoose from 'mongoose';

const documentSchema = new mongoose.Schema(
  {
    driver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    documentType: {
      type: String,
      enum: ['ID_FRONT_BACK', 'DRIVER_LICENSE', 'VEHICLE_REGISTRATION', 'INSURANCE'],
      required: true,
    },
    documentFiles: [{
      type: String,
    }],
    approvalStatus: {
      type: String,
      enum: ['Approved', 'Pending', 'Under Review', 'Rejected'],
      default: 'Pending',
    },
    expiresAt: { type: Date },
    notes: { type: String },
    requiresReupload: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

documentSchema.index({ driver: 1, documentType: 1 }, { unique: true });

export const Document = mongoose.model('Document', documentSchema);
