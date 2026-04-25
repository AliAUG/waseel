import 'dotenv/config';
import mongoose from 'mongoose';
import { RideType } from '../models/index.js';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/ridego';

const rideTypes = [
  { name: 'Economy', basePrice: 30000, timeEstimateMinutes: 3, vehicleTypeIcon: 'car', currency: 'LBP' },
  { name: 'Comfort', basePrice: 60000, timeEstimateMinutes: 5, vehicleTypeIcon: 'van', currency: 'LBP' },
  { name: 'Luxury', basePrice: 80000, timeEstimateMinutes: 8, vehicleTypeIcon: 'luxury', currency: 'LBP' },
];

async function seed() {
  await mongoose.connect(MONGODB_URI);
  await RideType.deleteMany({});
  await RideType.insertMany(rideTypes);
  console.log('Seed completed. Ride types:', rideTypes.map((r) => r.name).join(', '));
  await mongoose.disconnect();
}

seed().catch(console.error);
