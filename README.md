# 🐾 PawConnect — Social Platform for Dog Owners

**PawConnect** is a mobile-first software platform designed to connect dog owners for:

- Making new connections through swipe-based matchmaking (Tinder/Bumble-style)
- Organizing meetups and walks
- Real-time chatting
- Discovering nearby dog-friendly services (parks, groomers, clinics)
- Building a community of dog owners

---

## 📱 Platforms

- **Mobile App** — Built with Flutter (main platform)
- **Web App** *(optional)* — Angular or React

---

## 🧩 Core Features

- 🔐 **Authentication & Authorization** (JWT / OAuth2)
- 🐕 **User & Dog Profiles**
- ❤️ **Swipe + Match** mechanics (compatibility-based matching)
- 📍 **Geolocation Search** with interactive user map
- 💬 **Real-Time Chat** (WebSocket)
- 📅 **Meetups**: Create, accept, decline invitations
- 📌 **Place Finder**: Clinics, parks, pet services
- 💳 **Stripe Integration** for premium features

---

## ⚙️ Tech Stack

### 🔙 Backend

- Java 21 + Spring Boot  
- PostgreSQL
- Redis *(session & cache management)*  
- WebSocket *(real-time chat)*  
- REST API + Swagger/OpenAPI  
- Docker + Kubernetes (Azure AKS)  
- CI/CD: GitHub Actions

### 📱 Mobile App

- Flutter 3.x  
- Dio (HTTP requests)  
- flutter_bloc / provider (state management)  
- go_router (navigation)  
- Geolocator + Google Maps

---

## 🗂️ Repository Structure

```
/backend         # Spring Boot backend
/mobile-app      # Flutter mobile app
/web             # Optional frontend (Angular/React)
/docs            # Docs, diagrams, API specs
```

---

## 🛠️ Project Status

- 🔧 Active Development *(MVP phase)*
- 🧪 Modules in progress: auth, swipe, chat
- 🎯 Main focus: mobile app + RESTful backend
