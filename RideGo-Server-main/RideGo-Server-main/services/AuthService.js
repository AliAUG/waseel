import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { User, VerificationCode, UserSettings } from '../models/index.js';
import { mailService } from '../config/mail.js';

export class AuthService {
  static generateOTP() {
    return crypto.randomInt(100000, 999999).toString();
  }

  static generateToken(userId) {
    return jwt.sign(
      { userId },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
  }

  // Email-based OTP methods
  static async sendOTPByEmail(email, type = 'login') {
    const code = this.generateOTP();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 min

    await VerificationCode.create({
      email,
      code,
      type,
      expiresAt,
    });

    await mailService.sendOTP(email, code, type);
    return { expiresAt };
  }

  static async verifyOTPByEmail(email, code, type = 'login') {
    const verification = await VerificationCode.findOne({
      email,
      code,
      type,
      isUsed: false,
    });

    if (!verification) {
      throw new Error('Invalid or expired verification code');
    }

    if (new Date() > verification.expiresAt) {
      throw new Error('Verification code has expired');
    }

    verification.isUsed = true;
    await verification.save();

    return verification;
  }

  static async registerByEmail(data) {
    const { fullName, email, password, role,phoneNumber } = data;

    const existing = await User.findOne({ email });
    if (existing) {
      throw new Error('Email already registered');
    }

    const user = await User.create({
      fullName,
      email,
      password: password || undefined,
      role: role || 'Passenger',
      termsAndPrivacyAccepted: true,
      phoneNumber
    });

    const settings = await UserSettings.create({ user: user._id });
    user.settings = settings._id;
    await user.save();

    await this.sendOTPByEmail(email, 'account_creation');

    return { user, requiresVerification: true };
  }

  static async verifyEmailRegistration(email, code) {
    const verification = await this.verifyOTPByEmail(email, code, 'account_creation');

    const user = await User.findOne({ email });
    if (!user) {
      throw new Error('User not found');
    }

    user.isEmailVerified = true;
    await user.save();

    const token = this.generateToken(user._id);
    return { user, token };
  }

  static async loginByEmailOTP(email) {
    const user = await User.findOne({ email });
    if (!user) {
      throw new Error('No account found with this email');
    }

    await this.sendOTPByEmail(email, 'login');
    return { requiresVerification: true };
  }

  static async verifyEmailLogin(email, code) {
    await this.verifyOTPByEmail(email, code, 'login');

    const user = await User.findOne({ email }).select('-password');
    if (!user) {
      throw new Error('User not found');
    }

    const token = this.generateToken(user._id);
    return { user, token };
  }

  static async resetPasswordByEmail(email) {
    const user = await User.findOne({ email });
    if (!user) {
      throw new Error('No account found with this email');
    }

    await this.sendOTPByEmail(email, 'password_reset');
    return { requiresVerification: true };
  }

  static async resetPasswordVerify(email, code, newPassword) {
    const verification = await this.verifyOTPByEmail(email, code, 'password_reset');

    const user = await User.findOne({ email });
    if (!user) {
      throw new Error('User not found');
    }

    user.password = newPassword;
    await user.save();

    const token = this.generateToken(user._id);
    return { user, token };
  }



  static async loginByEmail(email, password) {
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      throw new Error('Invalid email or password');
    }

    const valid = await user.comparePassword(password);
    if (!valid) {
      throw new Error('Invalid email or password');
    }

    const token = this.generateToken(user._id);
    user.password = undefined;
    return { user, token };
  }

  static async getProfile(userId) {
    return User.findById(userId)
      .select('-password')
      .populate('settings');
  }
}
