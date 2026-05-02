import { Router } from 'express';
import { TripController } from '../controllers/TripController.js';
import { AuthMiddleware } from '../middleware/auth.js';

const router = Router();

router.get('/ride-types', TripController.getRideTypes);

router.use(AuthMiddleware.authenticate, AuthMiddleware.attachUser);

router.post('/', TripController.createTrip);
router.get('/', TripController.getTripHistory);
router.put('/:id/passenger-location', TripController.updatePassengerLiveLocation);
router.get('/:id/details', TripController.getTripDetails);
router.post('/:id/rate', TripController.rateTrip);
router.get('/:id', TripController.getTrip);

export const tripRoutes = router;
