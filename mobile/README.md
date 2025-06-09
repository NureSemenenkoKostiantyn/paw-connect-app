# PawConnect Mobile App

This directory contains the Flutter client for the PawConnect platform.

## Prerequisites

- **Flutter** 3.x installed and on your `PATH`
- A running PawConnect backend (Java Spring Boot)

### Start the backend

From the repository root:

```bash
cd backend
# using Docker
docker-compose up
# or using Maven
./mvnw spring-boot:run
```

The backend serves REST endpoints on `http://localhost:8080`.

### Run the Flutter app

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

The app reads the API base URL from the `API_BASE_URL` environment variable.
If not provided, it defaults to `http://localhost:8080`.

After signing in, the app automatically loads your profile and preferences.
If any required information is missing you will be redirected to the
multi‑step profile completion flow.  This wizard collects profile fields,
preference settings and at least one dog entry before navigating to the home
screen.
