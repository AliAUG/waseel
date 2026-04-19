import { Router } from 'express';
import { DeliveryController } from '../controllers/DeliveryController.js';
import { AuthMiddleware } from '../middleware/auth.js';

const router = Router();

router.use(AuthMiddleware.authenticate, AuthMiddleware.attachUser);

router.post('/', DeliveryController.createDelivery);
router.get('/', DeliveryController.getDeliveryHistory);
router.get('/:id', DeliveryController.getDelivery);
router.post('/:id/rate', DeliveryController.rateDelivery);

export const deliveryRoutes = router;
