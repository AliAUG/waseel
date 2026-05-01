import { Notification } from '../models/index.js';

export class NotificationService {
  static async getNotifications(userId, { category, page = 1, limit = 20 }) {
    const skip = (page - 1) * limit;
    const query = { user: userId };
    if (category && category !== 'All') {
      query.category = category;
    }

    const [notifications, total] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      Notification.countDocuments(query),
    ]);

    return { notifications, total, page, totalPages: Math.ceil(total / limit) };
  }

  static async markAsRead(userId, notificationId) {
    return Notification.findOneAndUpdate(
      { _id: notificationId, user: userId },
      { isRead: true },
      { new: true }
    );
  }

  static async markAllAsRead(userId) {
    await Notification.updateMany({ user: userId }, { isRead: true });
    return { message: 'All notifications marked as read' };
  }
}
