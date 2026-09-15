# Water Can Delivery App - Setup Guide

This guide explains how to set up, install, and run the Water Can Delivery App (both the Flutter Frontend and the Node.js/Express Backend) from scratch on a new PC.

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed on your machine:
1. **Node.js** (v18 or higher) - [Download Here](https://nodejs.org/)
2. **Flutter SDK** - [Download Here](https://docs.flutter.dev/get-started/install)
3. **Git** - [Download Here](https://git-scm.com/)

---

## 🚀 Step 1: Clone the Repository

Open your terminal or command prompt and run:
```bash
git clone <YOUR-GITHUB-REPO-URL>
cd WaterCanDeliveryApp
```

---

## ⚙️ Step 2: Backend Setup (Node.js & Supabase)

The backend is built with Express and connects to a Supabase PostgreSQL database.

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Configure Environment Variables
Inside the `backend` folder, create a `.env` file (if it doesn't already exist from the clone) and add your Supabase database credentials:

```env
PORT=3000
DB_USER=postgres
DB_PASSWORD=<YOUR-SUPABASE-PASSWORD>
DB_HOST=db.<YOUR-PROJECT-ID>.supabase.co
DB_PORT=5432
DB_NAME=postgres
```
### env file just replace with this detials belowh
PORT=3000
DB_USER=postgres
DB_PASSWORD=Ragul@2006ts
DB_HOST=db.boskkpdfwvonkvjabgfy.supabase.co
DB_PORT=5432
DB_NAME=postgres
### end of env
*Note: If you are setting up a brand new Supabase project for this PC, you will need to run the SQL queries located in `database/init.sql` inside the Supabase SQL Editor to create your tables.*

### 3. Start the Backend Server
```bash
npm run dev
```
You should see: `🚀 Server running on http://localhost:3000`

---

## 📱 Step 3: Frontend Setup (Flutter)

Open a **new terminal tab** (leave the backend running) and make sure you are in the root directory of the project (`WaterCanDeliveryApp`).

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Network IP Configuration (Important!)
By default, the Flutter app makes API requests to the backend using a hardcoded IP address. 
If you are running the app on a web browser on the same PC, or testing on a mobile device on your local Wi-Fi, you need to update the API endpoints in the code to match your computer's local IP address.

*Find your IP:*
- Windows: Open CMD and type `ipconfig` (Look for IPv4 Address)
- Mac: Open Terminal and type `ifconfig` or `ipconfig getifaddr en0`

*Update the Code:*
Search for `10.203.29.64` across the Flutter `lib` folder (e.g., in `login_screen.dart`, `register_screen.dart`, `order_controller.dart`, etc.) and replace it with your new IP address. Alternatively, use `localhost` if you are exclusively testing on Chrome Desktop.

### 3. Run the App
To run the app as a Web Server on your local network:
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```
*You can now open `http://<YOUR-IP>:8080` on any device on your Wi-Fi network to view the app!*

To run on a connected Android/iOS emulator or physical device:
```bash
flutter run
```

---

## 🎉 You're all set!
Your backend is connected to the cloud, and your frontend is successfully communicating with it. Happy coding!
