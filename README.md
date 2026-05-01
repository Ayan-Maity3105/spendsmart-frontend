# 💰 SpendSmart Frontend

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green?style=for-the-badge)

**A beautiful cross-platform expense tracking app with glassmorphism UI**

</div>

---

## 📌 Overview

SpendSmart Frontend is a **Flutter** application that provides a beautiful, modern expense tracking experience. Built with a glassmorphism design language, it connects to the SpendSmart Spring Boot backend via REST APIs with JWT authentication.

---

## ✨ Features

- 🎨 **Glassmorphism UI** — Premium frosted glass design
- 🌙 **Dark Theme** — Easy on the eyes
- 📊 **Interactive Charts** — Pie and bar charts for spending analysis
- 🔍 **Search & Filter** — Real-time search with debouncing
- 📅 **Date Range Filter** — Filter expenses by custom date range
- 🗂️ **Category Icons** — Visual category representation
- 🔐 **JWT Auth** — Secure token storage with SharedPreferences
- 📱 **Cross Platform** — Android, iOS and Web support
- ⚡ **Real-time Updates** — Instant UI refresh after operations

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter 3.x | UI Framework |
| Dart 3.x | Programming Language |
| http | REST API calls |
| shared_preferences | JWT token storage |
| fl_chart | Charts & graphs |
| provider | State management |

---

## 📁 Project Structure

```
lib/
│
├── models/
│   └── expense.dart              # Expense data model
│
├── services/
│   ├── auth_service.dart         # Auth API calls + token management
│   └── expense_service.dart      # Expense API calls
│
├── screens/
│   ├── LoginScreen.dart         # Login UI
│   ├── RegisterScreen.dart      # Register UI
│   ├── MainScreen.dart          # Bottom navigation container
│   ├── HomeScreen.dart          # Expense list + search + filter
│   ├── AddExpenseScreen.dart    # Add new expense
│   ├── EditExpenseScreen.dart   # Edit existing expense
│   ├── ChartsScreen.dart        # Pie & bar charts
│   └── ProfileScreen.dart       # User profile + logout
│
└── main.dart                     # App entry point
```

---

## 📱 Screens

| Screen | Description |
|---|---|
| Login | Glassmorphism login with email/password |
| Register | New user registration |
| Home | Expense list with search, filter and total |
| Add Expense | Form with category grid and date picker |
| Edit Expense | Pre-filled form for editing |
| Charts | Interactive pie and bar charts |
| Profile | User info and settings |

---

## 🎨 Design System

### Color Palette
```dart
Primary Background: #1A1A2E (Dark Navy)
Secondary Background: #16213E
Accent: #0F3460
Purple: #6C63FF
Blue: #3B82F6

Category Colors:
Food:          #FF6B6B (Red)
Transport:     #4ECDC4 (Teal)
Shopping:      #FFE66D (Yellow)
Education:     #6C63FF (Purple)
Health:        #FF8B94 (Pink)
Entertainment: #A8E6CF (Mint)
Other:         #95A5A6 (Grey)
```

### Glassmorphism Effect
```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  child: Container(
    color: Colors.white.withOpacity(0.05),
    border: Border.all(color: Colors.white.withOpacity(0.1)),
  ),
)
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Flutter 3.x SDK
- Dart 3.x
- Android Studio / VS Code
- Android/iOS device or emulator

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/Ayan-Maity3105/spendsmart-frontend.git
cd spendsmart-frontend
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Update API base URL**

In `lib/services/auth_service.dart`:
```dart
// Android Emulator
final String baseUrl = "http://10.0.2.2:8080/api/auth";

// Real Device (use your PC's IP)
final String baseUrl = "http://192.168.x.x:8080/api/auth";

// Web
final String baseUrl = "http://localhost:8080/api/auth";
```

In `lib/services/expense_service.dart`:
```dart
// Android Emulator
final String baseUrl = "http://10.0.2.2:8080/api/expenses";

// Real Device
final String baseUrl = "http://192.168.x.x:8080/api/expenses";

// Web
final String baseUrl = "http://localhost:8080/api/expenses";
```

**4. Run the app**
```bash
# Android/iOS
flutter run

# Web
flutter run -d chrome

# Specific device
flutter run -d <device_id>
```

---

## 🔌 API Integration

### Authentication Flow
```
Register → POST /api/auth/register
Login    → POST /api/auth/login → save JWT token
Logout   → delete token from SharedPreferences
```

### Token Management
```dart
// Save token after login
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setString("token", token);

// Use token in every request
headers: {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json"
}
```

### Expense Operations
```
GET    /api/expenses              → load all expenses
POST   /api/expenses              → add expense
PUT    /api/expenses/{id}         → update expense
DELETE /api/expenses/{id}         → delete expense
GET    /api/expenses/search       → search expenses
GET    /api/expenses/filter       → filter expenses
GET    /api/expenses/summary      → chart data
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  fl_chart: ^0.68.0
```

---

## 🚀 Build for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### Web
```bash
flutter build web --release
```

---

## 👨‍💻 Author

**Ayan Maity**
- GitHub: [@Ayan-Maity3105](https://github.com/Ayan-Maity3105)
- Stack: Flutter | Dart | Spring Boot | MySQL

---

## 🔗 Related Repository

- **Backend**: [spendsmart-backend](https://github.com/Ayan-Maity3105/spendsmart-backend) — Spring Boot REST API

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">
Built with ❤️ using Flutter
</div>
