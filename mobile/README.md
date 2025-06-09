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
flutter run
```

The app expects the backend to be reachable at `http://localhost:8080`.
