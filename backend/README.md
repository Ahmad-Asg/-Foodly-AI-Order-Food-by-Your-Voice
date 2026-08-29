# Foodly AI backend

This folder contains the Phase 4 database foundation and the Phase 5 Express API for **one** fictional restaurant: **Foodly AI Restaurant** in Faisalabad. It deliberately contains no authentication, checkout, OpenAI, AI chat, voice, or ordering logic.

## API endpoints

Every API response uses `{ "success": true, "data": ... }` for data or `{ "success": false, "message": "..." }` for errors.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/api/health` | Confirms the API is running. |
| GET | `/api/restaurant` | Returns the one Foodly AI Restaurant. |
| GET | `/api/categories` | Returns its menu categories. |
| GET | `/api/foods` | Returns available food items. |
| GET | `/api/foods/:id` | Returns one food item by MongoDB ID. |
| GET | `/api/menu` | Returns categories with their food items. |

Food filters may be combined:

```text
/api/foods?category=Burgers
/api/foods?maxPrice=800
/api/foods?spiceLevel=spicy
/api/foods?category=Burgers&maxPrice=800&spiceLevel=spicy
```

`spiceLevel` accepts `none`, `mild`, `medium`, `hot`, `extra_hot`, or the beginner-friendly alias `spicy`.

## Environment setup

Create the private file `backend/.env` from `.env.example`. It must contain your secret Atlas connection string and a port:

```env
MONGODB_URI=your-complete-atlas-connection-string
PORT=5000
```

`backend/.env` is ignored by Git. Never commit or share its contents.

## STEP 1 — Start the backend

### WHERE

VS Code terminal.

### COMMAND

```powershell
cd D:\Projects\Foodly-AI-Order-Food-by-Your-Voice\backend
npm start
```

### EXPECTED RESULT

```text
Connected to MongoDB database: foodly_ai
Foodly AI API is running on port 5000.
```

Keep this terminal open while testing the app. Press `Ctrl + C` in that terminal when you want to stop the server.

## STEP 2 — Check the API in your browser

### WHERE

Browser on your PC.

### URL

```text
http://localhost:5000/api/health
```

### EXPECTED RESULT

```json
{"success":true,"message":"Foodly AI API is running"}
```

## STEP 3 — Run Flutter on your physical Android phone

Your phone and PC must be on the same Wi-Fi network. A real phone cannot use `localhost` to reach your PC.

### WHERE

VS Code terminal at the project root.

### COMMAND

```powershell
cd D:\Projects\Foodly-AI-Order-Food-by-Your-Voice
flutter run -d RF8X40FPK6Z --dart-define=FOODLY_API_BASE_URL=http://192.168.0.107:5000/api
```

### EXPECTED RESULT

The app installs on your Samsung A15. `192.168.0.107` is this PC's current local network address. If your Wi-Fi changes, run `ipconfig` and use the IPv4 address shown for your active Wi-Fi adapter instead.

The Phase 3 UI remains intentionally mock-based. The Flutter API client at `lib/core/services/foodly_api_service.dart` is ready for later screens to use these real endpoints.

## Seed the development menu again

```powershell
cd D:\Projects\Foodly-AI-Order-Food-by-Your-Voice\backend
npm run seed
```

This resets only the temporary Foodly AI Restaurant categories and menu, then recreates one restaurant, nine categories, and 54 food items. Do not run it after making manual production menu edits.

## If something fails

Send the terminal error or a screenshot, but remove your MongoDB URI and password first.

## Authentication (Phase 6)

The API also provides secure account endpoints:

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | `/api/auth/register` | Creates an account and returns a JWT. |
| POST | `/api/auth/login` | Signs in and returns a JWT. |
| GET | `/api/auth/me` | Returns the signed-in user; requires a Bearer token. |
| PATCH | `/api/auth/me` | Updates the signed-in user's name; requires a Bearer token. |

Passwords are hashed with bcrypt before storage. The app stores the JWT in encrypted mobile storage and validates it with `/api/auth/me` each time it starts.

## STEP — Add the private JWT settings

### WHERE

VS Code, in the existing private file `backend/.env`.

### COMMAND

In a VS Code terminal, run this command once to generate a random secret:

```powershell
node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
```

### ACTION

Copy the generated value. In `backend/.env`, add these two lines below `MONGODB_URI`:

```env
JWT_SECRET=paste-the-generated-value-here
JWT_EXPIRES_IN=7d
```

Save the file. Do not share the generated value, and do not add it to `.env.example`.

### EXPECTED RESULT

Running `npm start` starts the API without a JWT configuration error. The login screen will then work when you run Flutter with the `FOODLY_API_BASE_URL` command above.
