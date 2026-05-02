import { Router } from 'express';
import { DriverController } from '../controllers/DriverController.js';
import { AuthMiddleware } from '../middleware/auth.js';

const router = Router();

router.use(AuthMiddleware.authenticate, AuthMiddleware.attachUser, AuthMiddleware.requireRole('Driver'));

router.get('/dashboard', DriverController.getDashboard);
router.get('/ride-requests', DriverController.getRideRequests);
router.post('/ride-requests/:id/accept', DriverController.acceptRideRequest);
router.post('/ride-requests/:id/decline', DriverController.declineRideRequest);

router.get('/trips', DriverController.getTripHistory);
router.get('/trips/:id', DriverController.getTrip);
router.put('/trips/:id/live-location', DriverController.updateDriverLiveLocation);
router.put('/trips/:id/status', DriverController.updateTripStatus);

router.get('/documents', DriverController.getDocuments);
router.post('/documents', DriverController.uploadDocument);

router.get('/wallet', DriverController.getWallet);
router.get('/transactions', DriverController.getTransactions);
router.post('/payout', DriverController.requestPayout);

export const driverRoutes = router;
