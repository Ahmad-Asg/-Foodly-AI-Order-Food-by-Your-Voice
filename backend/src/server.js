import 'dotenv/config';

import { app } from './app.js';
import { connectDatabase } from './config/database.js';

const port = Number(process.env.PORT) || 5000;

async function startServer() {
  await connectDatabase();
  app.listen(port, '0.0.0.0', () => {
    console.log(`Foodly AI API is running on port ${port}.`);
  });
}

startServer().catch((error) => {
  console.error(`Unable to start Foodly AI API: ${error.message}`);
  process.exit(1);
});
