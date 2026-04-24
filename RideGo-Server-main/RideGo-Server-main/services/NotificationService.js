import { Notification } from '../models/index.js';

export class NotificationService {
  /**
   * Persist an in-app notification (same document shape as GET /notifications).
   * Swallows errors so trip/delivery flows are not blocked by notification writes.
   */
  static async createForUser(userId, payload) {
    if (!userId) return null;
    const {
      type,
      category,
      title,
      message,
      icon = 'car',
      details,
    } = payload;
    try {
      return await Notification.create({
        user: userId,
        type,
        category,
        title,
        message,
        icon,
        ...(details !== undefined ? { details } : {}),
      });
    } catch (e) {
      console.error('[NotificationService.createForUser]', e?.message || e);
      return null;
    }
  }

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
