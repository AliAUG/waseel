import { Router } from 'express';
import { WalletController } from '../controllers/WalletController.js';
import { AuthMiddleware } from '../middleware/auth.js';

const router = Router();

router.use(AuthMiddleware.authenticate, AuthMiddleware.attachUser);

router.get('/', WalletController.getWallet);
router.post('/add-balance', WalletController.addBalance);
router.get('/transactions', WalletController.getTransactions);
router.get('/payment-methods', WalletController.getPaymentMethods);
router.post('/payment-methods', WalletController.addPaymentMethod);
router.put('/payment-methods/:id/default', WalletController.setDefaultPaymentMethod);

export const walletRoutes = router;
