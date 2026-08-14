# 🍽️ Restaurant Management System (Admin, Waiter & Kitchen)

A robust, real-time Restaurant Management Solution built with **Flutter** and **Firebase**. This system streamlines the communication between waiters, the kitchen, and management to ensure a seamless dining experience.

## 🌟 Key Features & Roles

### 👨‍💼 Admin Panel
- **Sales Analytics:** Track daily, weekly, and monthly revenue.
- **Order Overview:** Monitor all active and completed orders.
- **Vendor Management:** Manage different kitchen departments (e.g., Main Course, Drinks, Snacks).
- **Inventory & Menu:** Update food items, prices, and availability.

### 🤵 Waiter Module
- **Order Placement:** Quickly take orders for specific table numbers.
- **Real-time Status:** Get notified when an order is `Ready` for serving.
- **Bill Management:** Track pending and delivered orders per table.

### 🍳 Kitchen/Vendor Module
- **Live Order Stream:** Receive orders instantly as they are placed.
- **Item-wise Control:** Update status for individual items (`Pending` ➔ `Preparing` ➔ `Ready`).
- **Smart Filtering:** Filter orders by Vendor Type, Table Number, or Time.
- **Order History:** View completed tasks and total sales for the specific vendor.

## 🛠️ Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase Firestore (NoSQL Database)
- **State Management:** Provider
- **Real-time Sync:** Cloud Firestore Snapshots

## 📂 Project Architecture (Provider Logic)
The core logic resides in the `Provider` layer (e.g., `KitchenProvider`), which handles:
- **Filtering:** Advanced filtering based on `Date` (Today, Week, Month, Year).
- **Sorting:** Sort orders by `Table Number` or `Time`.
- **Status Updates:** Intelligent status management (e.g., when all items are 'Ready', the main order status updates automatically).

## 🚀 Installation & Setup

1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-username/Restaurent-Management-System.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Firebase Setup:**
   - Create a new Firebase project.
   - Add Android/iOS apps to your Firebase project.
   - Download and place `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) in their respective directories.
   - Enable Authentication and Firestore Database in the Firebase console.
4. **Run the app:**
   ```bash
   flutter run
   ```

## 📂 Project Structure
- `lib/features/admin`: Admin-specific screens and widgets.
- `lib/features/waiter`: Waiter-specific screens and widgets.
- `lib/features/kitchen`: Kitchen/Vendor-specific screens and widgets.
- `lib/model`: Data models.
- `lib/provider`: State management logic.
- `lib/utils`: Common widgets and utility functions.

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
