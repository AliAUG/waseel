import 'dotenv/config';
import app from './app.js';
import Database from './config/database.js';
import { mailService } from './config/mail.js';

const PORT = process.env.PORT || 3000;

async function start() {
  try {
    await Database.connect();
    mailService.init();

    app.listen(PORT, () => {
      console.log(`RideGO API running on http://localhost:${PORT}`);
      console.log(`API base: http://localhost:${PORT}/api`);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();
