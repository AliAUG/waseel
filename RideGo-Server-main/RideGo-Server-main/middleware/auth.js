import jwt from 'jsonwebtoken';
import { User } from '../models/index.js';
import { ApiResponse } from '../utils/ApiResponse.js';

export class AuthMiddleware {
  static authenticate(req, res, next) {
    const authHeader = req.headers.authorization;
    const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : null;

    if (!token) {
      return ApiResponse.error(res, 'Access denied. No token provided.', 401);
    }

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
      req.userId = decoded.userId;
      next();
    } catch (err) {
      return ApiResponse.error(res, 'Invalid or expired token.', 401);
    }
  }

  static async attachUser(req, res, next) {
    try {
      const user = await User.findById(req.userId).select('-password');
      if (!user) {
        return ApiResponse.error(res, 'User not found.', 404);
      }
      req.user = user;
      next();
    } catch (err) {
      return ApiResponse.error(res, 'User not found.', 404);
    }
  }

  static requireRole(...roles) {
    return (req, res, next) => {
      if (!req.user) {
        return ApiResponse.error(res, 'User not attached.', 401);
      }
      if (!roles.includes(req.user.role)) {
        return ApiResponse.error(res, 'Insufficient permissions.', 403);
      }
      next();
    };
  }
}
