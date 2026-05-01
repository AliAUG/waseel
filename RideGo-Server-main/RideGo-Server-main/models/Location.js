import mongoose from 'mongoose';

const locationSchema = new mongoose.Schema(
  {
    address: {
      type: String,
      required: true,
      trim: true,
    },
    latitude: { type: Number },
    longitude: { type: Number },
    details: { type: String, trim: true },
  },
  { _id: false }
);

export const Location = locationSchema;
