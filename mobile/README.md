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
# brings up PostgreSQL, Redis and optional PgAdmin services
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

All HTTP requests go through a shared `Dio` client defined in
`lib/src/services/http_client.dart`. The client stores cookies with a
`CookieJar` and uses a `CookieManager` interceptor so that the JWT cookie
received during sign‑in is automatically included in subsequent API calls.

Swipe-based matchmaking is powered by the [`flutter_card_swiper`](https://pub.dev/packages/flutter_card_swiper) package.

After signing in, the app automatically loads your profile and preferences.
If any required information is missing you will be redirected to the
multi‑step profile completion flow.  This wizard collects profile fields,
preference settings and at least one dog entry before navigating to the home
screen.
