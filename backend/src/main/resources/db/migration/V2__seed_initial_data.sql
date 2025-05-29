-- Roles (backed by ERole enum)
INSERT INTO roles (id, name) VALUES
                                 (1, 'ROLE_USER'),
                                 (2, 'ROLE_PREMIUM'),
                                 (3, 'ROLE_MODERATOR'),
                                 (4, 'ROLE_ADMIN');

-- Languages :contentReference[oaicite:1]{index=1}
INSERT INTO languages (id, code, name) VALUES
                                           (1, 'EN',  'English'),
                                           (2, 'ES',  'Spanish'),
                                           (3, 'DE',  'German');

-- Users :contentReference[oaicite:2]{index=2}
INSERT INTO users (
    id,
    username,
    email,
    password_hash,
    bio,
    birthdate,
    gender,
    location,
    location_visible,
    profile_photo_url,
    created_at
) VALUES
      (
          1,
          'alice',
          'alice@example.com',
          '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
          'Alice''s bio',
          DATE   '1990-01-01',
          'FEMALE',
          ST_GeogFromText('SRID=4326;POINT(-0.1278 51.5074)'),
          TRUE,
          'https://example.com/alice.jpg',
          TIMESTAMP '2025-05-28 09:00:00'
      ),
      (
          2,
          'bob',
          'bob@example.com',
          '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
          'Bob''s bio',
          DATE   '1985-06-15',
          'MALE',
          ST_GeogFromText('SRID=4326;POINT(-0.1425 51.5155)'),
          TRUE,
          'https://example.com/bob.jpg',
          TIMESTAMP '2025-05-28 09:05:00'
      );

-- User ↔ Role join (user_roles)
INSERT INTO user_roles (user_id, role_id) VALUES
                                              (1, 1),  -- Alice → ROLE_USER
                                              (2, 1),  -- Bob   → ROLE_USER
                                              (2, 2);  -- Bob   → ROLE_PREMIUM

-- User ↔ Language join (user_languages)
INSERT INTO user_languages (user_id, language_id) VALUES
                                                      (1, 1),  -- Alice → English
                                                      (2, 1),  -- Bob   → English
                                                      (2, 2);  -- Bob   → Spanish

-- Dogs :contentReference[oaicite:5]{index=5} (DogGender, Personality, ActivityLevel enums)
INSERT INTO dogs (
    id, name, breed, birthdate, size, gender, personality, activity_level, about, owner_id
) VALUES
      (1, 'Rex',  'Labrador', '2018-03-10', 'Large', 'MALE',      'FRIENDLY',   'HIGH',   'Energetic and playful', 1),
      (2, 'Lucy', 'Beagle',   '2020-07-20', 'Medium','FEMALE',    'CALM',      'MEDIUM', 'Calm and affectionate',  2);

-- Services :contentReference[oaicite:6]{index=6}
INSERT INTO services (
    id, name,        type,     latitude,    longitude,    rating
) VALUES
      (1, 'Central Park','PARK',   40.785091,   -73.968285,   4.7),
      (2, 'Happy Paws Vet','VET',  40.712776,   -74.005974,   4.5);

-- Chats :contentReference[oaicite:7]{index=7}
-- Using string here for clarity; if JPA mapped to ordinal, replace 'PRIVATE' with 0 :contentReference[oaicite:8]{index=8}
INSERT INTO chats (id, type, event_id) VALUES
    (1, 'PRIVATE', NULL);

-- Chat Participants :contentReference[oaicite:9]{index=9}
INSERT INTO chat_participants (chat_id, user_id) VALUES
                                                     (1, 1),
                                                     (1, 2);

-- Messages :contentReference[oaicite:10]{index=10}
INSERT INTO messages (
    id, content, timestamp, chat_id, sender_id
) VALUES
      (1, 'Hey Bob, how are you?',  '2025-05-28T09:10:00', 1, 1),
      (2, 'I’m good, thanks Alice!', '2025-05-28T09:12:00', 1, 2);

-- Matches :contentReference[oaicite:11]{index=11}
INSERT INTO matches (
    id, user1_id, user2_id, created_at
) VALUES
    (1, 1, 2, '2025-05-28T09:15:00');

-- Swipes :contentReference[oaicite:12]{index=12} (SwipeDecision enum: LIKE, PASS)
INSERT INTO swipes (
    id, liker_id, target_id, decision, timestamp
) VALUES
    (1, 1, 2, 'LIKE', '2025-05-28T09:20:00');

-- Payments :contentReference[oaicite:13]{index=13}
INSERT INTO payments (
    id, amount, currency, status,   timestamp,           user_id
) VALUES
      (1, 49.99, 'USD',    'PAID',  '2025-05-28T09:25:00', 1),
      (2, 19.99, 'USD',    'REFUNDED','2025-05-28T09:30:00', 2);


-- Ensure the users_id_seq sequence is synced with the max(id)
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('dogs_id_seq', (SELECT MAX(id) FROM dogs));
SELECT setval('services_id_seq', (SELECT MAX(id) FROM services));
SELECT setval('chats_id_seq', (SELECT MAX(id) FROM chats));
SELECT setval('messages_id_seq', (SELECT MAX(id) FROM messages));
SELECT setval('matches_id_seq', (SELECT MAX(id) FROM matches));
SELECT setval('swipes_id_seq', (SELECT MAX(id) FROM swipes));
SELECT setval('payments_id_seq', (SELECT MAX(id) FROM payments));
