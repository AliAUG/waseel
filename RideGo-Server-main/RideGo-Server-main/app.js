import express from 'express';
import cors from 'cors';
import routes from './routes/index.js';
import { ErrorHandler } from './middleware/errorHandler.js';

class App {
  constructor() {
    this.app = express();
    this.setupMiddleware();
    this.setupRoutes();
    this.setupErrorHandler();
  }

  setupMiddleware() {
    this.app.use(
      cors({
        origin: true,
        credentials: true,
        methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
      })
    );
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: true }));
  }

  setupRoutes() {
    this.app.use('/api', routes);
  }

  setupErrorHandler() {
    this.app.use(ErrorHandler.handle);
  }

  getApp() {
    return this.app;
  }
}

export default new App().getApp();
