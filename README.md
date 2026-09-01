# Foodly AI

> An AI-powered food ordering mobile application for a single restaurant in Faisalabad.

Foodly AI combines a Flutter mobile app with a Node.js backend, a real MongoDB menu, and a tool-enabled AI assistant. Customers can browse food, manage a cart, place orders, and ask for recommendations in English, Roman Urdu, or mixed language. Voice input uses the same trusted ordering flow as typed chat.

## Core features

- Secure registration, login, persistent sessions, and logout
- Real restaurant menu, categories, item details, availability, and prices from MongoDB
- Cart management, trusted server-side totals, checkout, and order history
- AI food assistant for menu recommendations, ingredients, budget, and spice preferences
- English, Roman Urdu, and mixed-language prompts
- AI-controlled cart changes using verified backend tools
- AI-assisted ordering with a delivery address and explicit confirmation
- Conversation memory with private, user-scoped conversations
- Android voice input, optional text-to-speech replies, and microphone language selection

## Tech stack

| Area | Technology |
| --- | --- |
| Mobile app | Flutter and Dart |
| Backend | Node.js and Express |
| Database | MongoDB Atlas and Mongoose |
| Authentication | JWT and bcryptjs |
| AI | OpenRouter with `openai/gpt-5-mini` and function calling |
| Voice | `speech_to_text` and `flutter_tts` |

## Architecture

```text
User
  ↓
Flutter app
  ↓
Node.js + Express API
  ├── Authentication service
  ├── Menu service
  ├── Cart service
  ├── Order service
  └── Conversation and AI services
          ↓
      OpenRouter → openai/gpt-5-mini
          ↓
      Verified AI tools
          ↓
       MongoDB Atlas
```

## How AI ordering works

The AI never writes directly to MongoDB. It can request a backend tool, but the backend validates every action and uses the same Cart and Order services as the normal app screens.

```text
"Add two Zinger Burgers"
        ↓
GPT-5 Mini selects a backend tool
        ↓
Backend searches the real MongoDB menu
        ↓
Cart service updates the signed-in user's cart
        ↓
Verified result is returned to the AI
        ↓
Foodly AI replies with the real cart state
```

Order creation additionally requires a delivery address and an explicit confirmation. Prices and totals always come from the server, not the AI or Flutter client.

## Sample AI commands

- `Mujhe 1000 ke andar spicy burger suggest kro`
- `2 Zinger Burgers cart mein add kro`
- `Mera total kitna hai?`
- `Order place krdo`

## Security and data integrity

- API keys and database credentials stay in `backend/.env`; that file is ignored by Git.
- JWT protects private cart, order, profile, and conversation endpoints.
- Every cart, order, and AI action is scoped to the authenticated user.
- MongoDB is the source of truth for the menu, availability, prices, and order snapshots.
- The AI cannot override food prices or create an order without backend confirmation.

## Local setup

### 1. Clone and install Flutter dependencies

```powershell
git clone https://github.com/Ahmad-Asg/-Foodly-AI-Order-Food-by-Your-Voice.git
cd Foodly-AI-Order-Food-by-Your-Voice
flutter pub get
```

### 2. Configure the backend

```powershell
cd backend
npm install
Copy-Item .env.example .env
```

Edit `backend/.env` and provide values for the variable names below. Do not commit this file.

```text
PORT
MONGODB_URI
JWT_SECRET
JWT_EXPIRES_IN
OPENROUTER_API_KEY
OPENROUTER_MODEL
```

Seed the single-restaurant menu, then start the API:

```powershell
npm run seed
npm start
```

### 3. Run the Flutter app

Open another terminal in the project root. For an Android phone on the same Wi-Fi network, replace `YOUR_COMPUTER_IP` with your computer's current IPv4 address.

```powershell
flutter run -d YOUR_DEVICE_ID --dart-define=FOODLY_API_BASE_URL=http://YOUR_COMPUTER_IP:5000/api
```

For the Android emulator, use `http://10.0.2.2:5000/api` as the API base URL.

## Screenshots

Add real screenshots before presenting the project publicly. Recommended captures:

1. Menu and food details
2. AI chat showing a grounded recommendation
3. Voice listening state
4. Cart and checkout
5. Confirmed order and order history

## Project status

**Core portfolio version complete.**

## Future improvements

- Favorites and reviews
- Advanced personalization
- Realtime full-duplex AI voice
- Payment gateway integration
- Restaurant admin panel
- Push notifications

