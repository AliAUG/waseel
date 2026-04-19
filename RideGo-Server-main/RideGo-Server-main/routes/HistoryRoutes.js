import { Router } from 'express';
import { HistoryController } from '../controllers/HistoryController.js';
import { AuthMiddleware } from '../middleware/auth.js';

const router = Router();

router.use(AuthMiddleware.authenticate, AuthMiddleware.attachUser);

router.get('/', HistoryController.getHistory);
router.get('/trips/:id', HistoryController.getTripDetails);
router.get('/deliveries/:id', HistoryController.getDeliveryDetails);

export const historyRoutes = router;
