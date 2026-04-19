import mongoose from 'mongoose';

class Database {
  static async connect() {
    const uri = process.env.MONGODB_URI
    await mongoose.connect(uri);
    console.log('MongoDB connected');
  }

  static async disconnect() {
    await mongoose.disconnect();
    console.log('MongoDB disconnected');
  }
}

export default Database;
