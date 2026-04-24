import mongoose from 'mongoose';

class Database {
  static async connect() {
    const uri = process.env.MONGODB_URI?.trim();
    if (!uri) {
      throw new Error(
        'MONGODB_URI is not set. Copy .env.example to .env in RideGo-Server-main/RideGo-Server-main and set MONGODB_URI (e.g. mongodb://localhost:27017/ridego or your Atlas connection string).'
      );
    }
    await mongoose.connect(uri);
    console.log('MongoDB connected');
  }

  static async disconnect() {
    await mongoose.disconnect();
    console.log('MongoDB disconnected');
  }
}

export default Database;
