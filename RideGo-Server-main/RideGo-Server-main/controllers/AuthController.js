import { AuthService } from '../services/AuthService.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class AuthController {
  static async loginByEmail(req, res) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return ApiResponse.error(res, 'Email and password are required', 400);
      }

      const result = await AuthService.loginByEmail(email, password);

      return ApiResponse.success(res, {
        user: result.user,
        token: result.token,
      });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async getProfile(req, res) {
    try {
      const user = await AuthService.getProfile(req.userId);
      return ApiResponse.success(res, user);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  // Email-based OTP methods
  static async sendOTPByEmail(req, res) {
    try {
      const { email, type } = req.body;
      if (!email) {
        return ApiResponse.error(res, 'Email is required', 400);
      }

      await AuthService.sendOTPByEmail(email, type || 'login');
      return ApiResponse.success(res, { message: 'Verification code sent to your email' });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async registerByEmail(req, res) {
    try {
      const { fullName, email, password, role, phoneNumber } = req.body;

      if (!fullName || !email || !password) {
        return ApiResponse.error(res, 'Full name, email, and password are required', 400);
      }

      const result = await AuthService.registerByEmail({
        fullName,
        email,
        password,
        role,
        phoneNumber
      });

      return ApiResponse.success(res, { message: 'Verification code sent to your email' }, 'Account created', 201);
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async verifyEmailRegistration(req, res) {
    try {
      const { email, code } = req.body;

      if (!email || !code) {
        return ApiResponse.error(res, 'Email and code are required', 400);
      }

      const result = await AuthService.verifyEmailRegistration(email, code);

      return ApiResponse.success(res, {
        user: result.user,
        token: result.token,
      });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async loginByEmailOTP(req, res) {
    try {
      const { email } = req.body;

      if (!email) {
        return ApiResponse.error(res, 'Email is required', 400);
      }

      await AuthService.loginByEmailOTP(email);

      return ApiResponse.success(res, { message: 'Verification code sent to your email' });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async verifyEmailLogin(req, res) {
    try {
      const { email, code } = req.body;

      if (!email || !code) {
        return ApiResponse.error(res, 'Email and code are required', 400);
      }

      const result = await AuthService.verifyEmailLogin(email, code);

      return ApiResponse.success(res, {
        user: result.user,
        token: result.token,
      });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async resetPasswordByEmail(req, res) {
    try {
      const { email } = req.body;

      if (!email) {
        return ApiResponse.error(res, 'Email is required', 400);
      }

      await AuthService.resetPasswordByEmail(email);

      return ApiResponse.success(res, { message: 'Password reset code sent to your email' });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }

  static async resetPasswordVerify(req, res) {
    try {
      const { email, code, newPassword } = req.body;

      if (!email || !code || !newPassword) {
        return ApiResponse.error(res, 'Email, code, and new password are required', 400);
      }

      const result = await AuthService.resetPasswordVerify(email, code, newPassword);

      return ApiResponse.success(res, {
        user: result.user,
        token: result.token,
      });
    } catch (err) {
      return ApiResponse.error(res, err.message, 400);
    }
  }
}
