import 'dotenv/config';
import app from './app.js';
import Database from './config/database.js';
import { mailService } from './config/mail.js';

const PORT = process.env.PORT || 3000;

async function start() {
  try {
    await Database.connect();
    mailService.init();

    const server = app.listen(PORT, '0.0.0.0', () => {
      console.log(`RideGO API running on http://localhost:${PORT} (all interfaces)`);
      console.log(`API base: http://localhost:${PORT}/api`);
    });

    server.on('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        console.error('\n[!] Port %s is already in use (EADDRINUSE).', PORT);
        console.error(
          '    Usually another `npm start` / Node process is still running — not a MongoDB failure.'
        );
        console.error(
          '    If you see "MongoDB connected" above, the database is fine; only HTTP bind failed.'
        );
        console.error('    Stop the other server (Ctrl+C in its terminal), or free the port:');
        console.error(
          `       PIDS=$(lsof -t -iTCP:${PORT} -sTCP:LISTEN); [ -n "$PIDS" ] && kill $PIDS`
        );
        console.error('    (If that prints nothing, the port is already free — run npm start again.)');
      } else {
        console.error('HTTP server error:', err);
      }
      process.exit(1);
    });
  } catch (err) {
    console.error('Failed to start server:', err);
    process.exit(1);
  }
}

start();
