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

## Frontend

```bash
cd frontend
npm install
npm run dev
```

The app runs on `http://localhost:5173`.

## Docker

```bash
docker compose up --build
```

This starts MongoDB, the backend API, and the frontend at `http://localhost:5173`.
