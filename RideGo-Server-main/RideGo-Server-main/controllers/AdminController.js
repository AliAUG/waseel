import { AdminService } from '../services/AdminService.js';

export class AdminController {
  static async createTrip(req, res) {
    try {
      const result = await AdminService.createTrip(req.body);
      res.status(201).json(result);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  }

  static async getTrips(req, res) {
    try {
      const result = await AdminService.getTrips(req.query);
      res.json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }

  static async getTripById(req, res) {
    try {
      const result = await AdminService.getTripById(req.params.id);
      res.json(result);
    } catch (err) {
      res.status(404).json({ message: err.message });
    }
  }

  static async updateTrip(req, res) {
    try {
      const result = await AdminService.updateTrip(req.params.id, req.body);
      res.json(result);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  }

  static async deleteTrip(req, res) {
    try {
      const result = await AdminService.deleteTrip(req.params.id);
      res.json(result);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  }

  static async updateStatus(req, res) {
    try {
      const result = await AdminService.updateStatus(req.params.id, req.body.status);
      res.json(result);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  }

  static async assignDriver(req, res) {
    try {
      const result = await AdminService.assignDriver(req.params.id, req.body.driverId);
      res.json(result);
    } catch (err) {
      res.status(400).json({ message: err.message });
    }
  }

  static async getPassengers(req, res) {
    try {
      const result = await AdminService.getPassengers();
      res.json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }

  static async getDrivers(req, res) {
    try {
      const result = await AdminService.getDrivers();
      res.json(result);
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  }
}