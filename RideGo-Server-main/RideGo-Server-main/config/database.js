import mongoose from 'mongoose';

class Database {
  static async connect() {
    const uri = process.env.MONGODB_URI;
    if (uri == null || String(uri).trim() === '') {
      throw new Error(
        'MONGODB_URI is not set. In RideGo-Server-main/RideGo-Server-main, copy .env.example to .env and set MONGODB_URI (e.g. mongodb://127.0.0.1:27017/ridego).',
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
