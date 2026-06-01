# 💰 Full-Stack Expense Tracker

A production-ready Expense Tracker application built with **Spring Boot**, **MongoDB**, **React**, and **Flutter**.

The application allows users to manage personal finances by tracking income and expenses, organizing transactions into categories, viewing financial reports, and accessing the platform from both web and mobile devices.

---

## 🚀 Features

### 🔐 Authentication & Security

* User Registration
* User Login
* JWT Authentication
* Password Encryption using BCrypt
* Protected API Routes

### 👤 User Management

* Profile Management
* Currency Selection
* Profile Updates

### 📂 Categories

* Create Categories
* Update Categories
* Delete Categories
* Custom Expense Categories

### 💳 Transactions

* Add Income
* Add Expenses
* Edit Transactions
* Delete Transactions
* Search Transactions
* Filter Transactions
* Pagination Support

### 📊 Reports & Analytics

* Total Income
* Total Expenses
* Current Balance
* Monthly Trends
* Category-Based Spending
* Financial Dashboard
* Interactive Charts

### 🌐 Cross Platform

* Responsive Web Application
* Android Application
* iOS Application

---

# 🛠 Tech Stack

## Backend

* Java
* Spring Boot 3
* Spring Security
* JWT Authentication
* Spring Data MongoDB
* MongoDB Atlas
* Maven

## Frontend

* React
* Vite
* Tailwind CSS
* Axios
* React Router DOM
* React Hook Form
* Recharts
* React Toastify

## Mobile

* Flutter
* Dart

## Database

* MongoDB
* MongoDB Atlas

## Deployment

* Render (Backend)
* Vercel (Frontend)
* MongoDB Atlas (Database)

---

# 📁 Project Structure

```bash
expense-tracker/
│
├── backend/
│   ├── src/
│   ├── pom.xml
│
├── frontend/
│   ├── src/
│   ├── package.json
│
├── mobile/
│   ├── lib/
│   ├── pubspec.yaml
│
└── docker-compose.yml
```

---

# ⚙️ Backend Setup

## Prerequisites

* Java 21+
* Maven
* MongoDB

## Run Backend

```bash
cd backend
mvn spring-boot:run
```

Backend runs on:

```text
http://localhost:8080
```

Swagger Documentation:

```text
http://localhost:8080/swagger-ui.html
```

### Environment Variables

```env
MONGODB_URI=mongodb://localhost:27017/expense_tracker
JWT_SECRET=your-super-secret-key
```

---

# 🌐 Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

Frontend runs on:

```text
http://localhost:5173
```

---

# 📱 Mobile Setup

```bash
cd mobile
flutter pub get
flutter run
```

For Android Emulator:

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8080
```

For Physical Device:

```bash
flutter run --dart-define=API_URL=http://YOUR_LOCAL_IP:8080
```

Example:

```bash
flutter run --dart-define=API_URL=http://192.168.1.20:8080
```

---

# 🐳 Docker Setup

Start all services:

```bash
docker compose up --build
```

This starts:

* MongoDB
* Spring Boot Backend
* React Frontend

Frontend:

```text
http://localhost:5173
```

Backend:

```text
http://localhost:8080
```

---

# 📸 Screenshots

Add screenshots of:

* Login Page
* Dashboard
* Transactions
* Categories
* Reports
* Mobile Application

---

# 🎯 Future Improvements

* Budget Goals
* Recurring Transactions
* Email Notifications
* Export Reports as PDF
* Export Data to Excel
* Multi-Currency Support
* AI Spending Insights

---

# 👨‍💻 Author

**Keshma Eesara Salgado**

Computer Science Student | Full-Stack Developer | React & Spring Boot Developer

* React
* Spring Boot
* Flutter
* MongoDB
* Three.js
* React Three Fiber

If you found this project useful, consider giving it a ⭐ on GitHub.
