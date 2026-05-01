import { User, UserSettings, SavedPlace } from '../models/index.js';

export class UserService {
  static async updateProfile(userId, data) {
    const { fullName, email, profilePicture } = data;

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: { fullName, email, profilePicture } },
      { new: true, runValidators: true }
    ).select('-password');

    return user;
  }

  static async getSettings(userId) {
    let settings = await UserSettings.findOne({ user: userId });
    if (!settings) {
      settings = await UserSettings.create({ user: userId });
    }
    return settings;
  }

  static async updateSettings(userId, data) {
    const settings = await UserSettings.findOneAndUpdate(
      { user: userId },
      { $set: data },
      { new: true, upsert: true }
    );
    return settings;
  }

  static async getSavedPlaces(userId) {
    return SavedPlace.find({ user: userId }).sort({ order: 1 });
  }

  static async addSavedPlace(userId, data) {
    const count = await SavedPlace.countDocuments({ user: userId });
    return SavedPlace.create({
      user: userId,
      ...data,
      order: count,
    });
  }

  static async updateSavedPlace(userId, placeId, data) {
    const place = await SavedPlace.findOneAndUpdate(
      { _id: placeId, user: userId },
      { $set: data },
      { new: true }
    );
    return place;
  }

  static async deleteSavedPlace(userId, placeId) {
    await SavedPlace.findOneAndDelete({ _id: placeId, user: userId });
    return { deleted: true };
  }
}
