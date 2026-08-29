import 'dotenv/config';

import { app } from './app.js';
import { connectDatabase } from './config/database.js';

const port = Number(process.env.PORT) || 5000;

async function startServer() {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is missing. Add it to backend/.env before starting the API.');
  }
  await connectDatabase();
  app.listen(port, '0.0.0.0', () => {
    console.log(`Foodly AI API is running on port ${port}.`);
  });
}

startServer().catch((error) => {
  console.error(`Unable to start Foodly AI API: ${error.message}`);
  process.exit(1);
});
