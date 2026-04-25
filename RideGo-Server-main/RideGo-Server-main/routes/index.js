import { Router } from 'express';
import { DeliveryController } from '../controllers/DeliveryController.js';
import { AuthMiddleware } from '../middleware/auth.js';
import { AuthRoutes } from './AuthRoutes.js';
import { userRoutes } from './UserRoutes.js';
import { tripRoutes } from './TripRoutes.js';
import { deliveryRoutes } from './DeliveryRoutes.js';
import { walletRoutes } from './WalletRoutes.js';
import { driverRoutes } from './DriverRoutes.js';
import { notificationRoutes } from './NotificationRoutes.js';
import { historyRoutes } from './HistoryRoutes.js';
import { AdminRoutes } from './AdminRoutes.js';

const router = Router();

router.use('/auth', AuthRoutes.register());
router.use('/users', userRoutes);
router.use('/trips', tripRoutes);
// Registered here (not only under nested /deliveries router) so POST /api/deliveries/complete always resolves.
router.post(
  '/deliveries/complete',
  AuthMiddleware.authenticate,
  AuthMiddleware.attachUser,
  DeliveryController.completeDeliveryByBody,
);
router.use('/deliveries', deliveryRoutes);
router.use('/wallet', walletRoutes);
router.use('/driver', driverRoutes);
router.use('/notifications', notificationRoutes);
router.use('/history', historyRoutes);
router.use('/admin', AdminRoutes.register());

router.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'RideGO API' });
});

export default router;
