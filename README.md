# 🐾 PawConnect — Social Platform for Dog Owners 

**PawConnect** is a mobile-first software platform designed to connect dog owners for:

- Making new connections through swipe-based matchmaking (Tinder/Bumble-style)
- Organizing meetups and walks
- Real-time chatting
- Building a community of dog owners

---

## 📱 Platforms

- **Mobile App** — Built with Flutter

---

## 🧩 Core Features

- 🔐 **Authentication & Authorization** (JWT / OAuth2)
- 🐕 **User & Dog Profiles**
- ❤️ **Swipe + Match** mechanics (compatibility-based matching)
- 📍 **Geolocation Search** with interactive user map
- 💬 **Real-Time Chat** (WebSocket)
- 📅 **Meetups**: Create, accept, decline invitations

---

## ⚙️ Tech Stack

### 🔙 Backend

- Java 21 + Spring Boot  
- PostgreSQL
- Redis *(cache management)*  
- WebSocket *(real-time chat)*  
- REST API + Swagger/OpenAPI  
- Docker + Kubernetes (Azure AKS)  

### 📱 Mobile App

- Flutter 3.x  
- Dio (HTTP requests)  
- go_router (navigation)  
- Geolocator + OpenStreetMap

---

## 🗂️ Repository Structure

```
/backend         # Spring Boot backend
/mobile          # Flutter mobile app
```

---

## 🛠️ Project Status

- 🔧 Active Development *(MVP phase)*
- 🎯 Main focus: mobile app + RESTful backend

## WebSocket API

The backend exposes a STOMP endpoint at `/ws-chat`. The handshake requires a valid JWT,
so include the token in the `Authorization` header (or cookie) when connecting
with a WebSocket or SockJS client. Each message is sent on behalf of the authenticated
`Principal` from the WebSocket session. The controller places that authentication into
the `SecurityContext` before saving the message so that regular service-layer security
checks continue to work.

### Endpoints

- Chats are automatically created when two users match.
- `/app/chat.send` – send a message to a chat; messages appear on `/topic/chats/{chatId}`.
- `GET /api/chats/{chatId}/messages` – retrieve chat history paged by `page` and `limit`.

### REST Endpoints

- `GET /api/chats` – list chats for the current user. Each item is a `ChatResponse`.

`ChatResponse` fields:

- `id` – chat ID.
- `type` – `PRIVATE` or `GROUP`.
- `eventId` – associated event ID if the chat is for an event.
- `participantIds` – user IDs participating in the chat.
- `lastMessage` – details of the most recent message (or `null`).
- `unreadCount` – number of unread messages for the requesting user.

  
