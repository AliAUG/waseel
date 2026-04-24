import { Router } from 'express';
import { UserController } from '../controllers/UserController.js';
import { AuthMiddleware } from '../middleware/auth.js';

const router = Router();

router.use(AuthMiddleware.authenticate, AuthMiddleware.attachUser);

router.get('/settings', UserController.getSettings);
router.put('/settings', UserController.updateSettings);
router.put('/profile', UserController.updateProfile);

router.get('/saved-places', UserController.getSavedPlaces);
router.post('/saved-places', UserController.addSavedPlace);
router.put('/saved-places/:id', UserController.updateSavedPlace);
router.delete('/saved-places/:id', UserController.deleteSavedPlace);

export const userRoutes = router;
