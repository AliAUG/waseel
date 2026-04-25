import { Router } from "express";
import { AdminController } from "../controllers/AdminController.js";
import { AuthMiddleware } from "../middleware/auth.js";

export class AdminRoutes {
  static router = Router();

  static getRouter() {
    return this.router;
  }

  static register() {
    this.router.get(
      "/passengers",
      AdminController.getPassengers,
    );

    this.router.get(
      "/drivers",
      AdminController.getDrivers,
    );

    // CRUD
    this.router.post(
      "/",
      AdminController.createTrip,
    );
    this.router.get("/", AdminController.getTrips);
    this.router.get(
      "/:id",
      AdminController.getTripById,
    );
    this.router.put(
      "/:id",
      AdminController.updateTrip,
    );
    this.router.delete(
      "/:id",
      AdminController.deleteTrip,
    );

    // Extra actions
    this.router.patch(
      "/:id/status",
      AdminController.updateStatus,
    );
    this.router.patch(
      "/:id/assign-driver",
      AdminController.assignDriver,
    );

    return this.router;
  }
}
