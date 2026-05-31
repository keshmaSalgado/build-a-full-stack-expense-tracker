# Full-Stack Expense Tracker

Production-minded expense tracker with a Spring Boot 3 API and Vite React dashboard.

## Backend

```bash
cd backend
mvn spring-boot:run
```

The API runs on `http://localhost:8080`. Swagger UI is available at `http://localhost:8080/swagger-ui.html`.

Required services/config:

- MongoDB database `expense_tracker`
- `MONGODB_URI`, for example `mongodb://localhost:27017/expense_tracker`
- `JWT_SECRET` should be a long random secret in production

The backend also loads `backend/.env` automatically for local development.

## Frontend

```bash
cd frontend
npm install
npm run dev
```

The app runs on `http://localhost:5173`.

## Mobile

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:8080
```

Use `10.0.2.2` for the Android emulator. For a physical phone, replace it with your computer's LAN IP, for example `http://192.168.1.20:8080`.

## Docker

```bash
docker compose up --build
```

This starts MongoDB, the backend API, and the frontend at `http://localhost:5173`.
