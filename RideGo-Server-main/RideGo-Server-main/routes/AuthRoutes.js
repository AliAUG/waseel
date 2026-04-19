import { Router } from 'express';
import { AuthController } from '../controllers/AuthController.js';
import { AuthMiddleware } from '../middleware/auth.js';

export class AuthRoutes {
  static router = Router();

  static getRouter() {
    return this.router;
  }

  static register() {
    this.router.post('/login/email', AuthController.loginByEmail);

    // Email OTP endpoints
    this.router.post('/send-otp/email', AuthController.sendOTPByEmail);
    this.router.post('/register/email', AuthController.registerByEmail);
    this.router.post('/verify-registration/email', AuthController.verifyEmailRegistration);
    this.router.post('/login/email/otp', AuthController.loginByEmailOTP);
    this.router.post('/login/email/otp/verify', AuthController.verifyEmailLogin);
    this.router.post('/reset-password/email', AuthController.resetPasswordByEmail);
    this.router.post('/reset-password/email/verify', AuthController.resetPasswordVerify);

    this.router.get(
      '/profile',
      AuthMiddleware.authenticate,
      AuthMiddleware.attachUser,
      AuthController.getProfile
    );

    return this.router;
  }
}
