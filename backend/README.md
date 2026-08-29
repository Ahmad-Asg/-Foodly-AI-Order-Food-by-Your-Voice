# Foodly AI database foundation

This folder contains **Phase 4 only**: MongoDB/Mongoose data schemas and a development seed for one fictional restaurant, **Foodly AI Restaurant**. It does not contain an Express server, APIs, login, OpenAI integration, or Flutter integration.

## Data model

- One `Restaurant` record, enforced by the unique `isPrimary` flag
- Nine `Category` records and 54 `FoodItem` records belonging to that restaurant
- `User` with non-sensitive food preferences
- `Cart` and `Order` items that reference real `FoodItem` IDs
- `Review`, `Favorite`, `Conversation`, and `Message` structures

Prices are PKR numbers. A future backend must retrieve food items by ID and calculate prices from MongoDB; it must not trust names or prices supplied by a user or AI response.

## STEP 1 — Install Node.js

### WHAT WE ARE DOING

Installing Node.js so the Mongoose schemas and seed command can run.

### WHERE

Browser, then PowerShell.

### WHAT TO CLICK

1. Open [nodejs.org](https://nodejs.org/).
2. Download the **LTS** version for Windows.
3. Run the installer and keep the default options.
4. Close and reopen PowerShell after the installation finishes.

### COMMAND

```powershell
node --version
npm --version
```

### EXPECTED RESULT

Both commands print version numbers.

## STEP 2 — Create MongoDB Atlas database

### WHAT WE ARE DOING

Creating the cloud database where Foodly AI's one restaurant and menu will be stored.

### WHERE

Browser: [MongoDB Atlas](https://www.mongodb.com/atlas/database).

### WHAT TO CLICK

1. Sign in or create an Atlas account.
2. Choose **Create** → **Database** and select the free tier if it is suitable for you.
3. Create a database user under **Security** → **Database Access**. Save its username and password somewhere private.
4. Under **Security** → **Network Access**, add your current IP address. For local development only, you may choose **Allow Access from Anywhere**.
5. Open **Database** → **Connect** → **Drivers** → **Node.js**.
6. Copy the connection string and replace `<password>` with your database-user password.

## STEP 3 — Add your private connection string

### WHAT WE ARE DOING

Adding your Atlas connection string locally without committing it to Git.

### WHERE

VS Code.

### FILE

`backend/.env`

### WHAT TO DO

Copy `backend/.env.example`, rename the copy to `.env`, and replace its value with your complete Atlas connection string.

### CODE

```env
MONGODB_URI=your-complete-atlas-connection-string
```

`backend/.env` is ignored by Git. Never paste its value into chat, source code, or GitHub.

## STEP 4 — Install database packages and seed the menu

### WHERE

PowerShell in the `backend` folder.

### COMMAND

```powershell
cd D:\Projects\Foodly-AI-Order-Food-by-Your-Voice\backend
npm install
npm run seed
```

### EXPECTED RESULT

The final command reports a MongoDB connection and then:

```text
Created 1 restaurant, 9 categories, and 54 food items.
```

The seed command is repeatable. It resets the temporary Foodly AI Restaurant categories and menu before recreating them, so do not use it after making manual production menu edits.

## IF IT FAILS

Send a screenshot or copy the full PowerShell error. Do not include your MongoDB connection string or password.
