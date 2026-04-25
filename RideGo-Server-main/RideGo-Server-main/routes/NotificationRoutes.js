import { Router } from 'express';
import { NotificationController } from '../controllers/NotificationController.js';
import { AuthMiddleware } from '../middleware/auth.js';

const router = Router();

router.use(AuthMiddleware.authenticate, AuthMiddleware.attachUser);

router.get('/', NotificationController.getNotifications);
router.put('/read-all', NotificationController.markAllAsRead);
router.put('/:id/read', NotificationController.markAsRead);

export const notificationRoutes = router;
