-- V3__seed_manual_test_data.sql
-- Manual-testing fixtures.  DO NOT run in production.
-- ---------------------------------------------------

---------------------------------------------------------------------------
-- 1. Users
---------------------------------------------------------------------------
INSERT INTO users (
    id, username, email, password_hash, bio, birthdate, gender,
    location, location_visible, profile_photo_url, created_at
) VALUES
      (1, 'alice', 'alice@example.com',
       '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Alice''s bio', DATE '1990-01-01', 'FEMALE',
       ST_GeogFromText('SRID=4326;POINT(-0.1278 51.5074)'),
       TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 09:00:00'),
      (2, 'bob',   'bob@example.com',
       '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Bob''s bio',   DATE '1985-06-15', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(-0.1425 51.5155)'),
       TRUE, 'placeholder/PlaceholderUser.webp',   TIMESTAMP '2025-05-28 09:05:00');

---------------------------------------------------------------------------
-- 2. User ↔ Role
---------------------------------------------------------------------------
INSERT INTO user_roles (user_id, role_id) VALUES
                                              (1, 1),   -- Alice → ROLE_USER
                                              (2, 1),   -- Bob   → ROLE_USER
                                              (2, 2);   -- Bob   → ROLE_PREMIUM

---------------------------------------------------------------------------
-- 3. User ↔ Language
---------------------------------------------------------------------------
INSERT INTO user_languages (user_id, language_id) VALUES
                                                      (1, 1),   -- Alice → English
                                                      (2, 1),   -- Bob   → English
                                                      (2, 2);   -- Bob   → Spanish

---------------------------------------------------------------------------
-- 4. Dogs
---------------------------------------------------------------------------
INSERT INTO dogs (
    id, name, breed, birthdate, size, gender,
    personality, activity_level, about, owner_id
) VALUES
      (1, 'Rex',  'Labrador', DATE '2018-03-10', 'LARGE',  'MALE',
       'FRIENDLY', 'HIGH',   'Energetic and playful', 1),
      (2, 'Lucy', 'Beagle',   DATE '2020-07-20', 'MEDIUM', 'FEMALE',
       'CALM',     'MEDIUM', 'Calm and affectionate', 2);
INSERT INTO dog_photo_urls (dog_id, photo_urls) VALUES
  (1, 'placeholder/DogPlaceholder1.webp'),
  (1, 'placeholder/DogPlaceholder2.webp'),
  (2, 'placeholder/DogPlaceholder1.webp'),
  (2, 'placeholder/DogPlaceholder2.webp');

---------------------------------------------------------------------------
-- 5. Services (park, vet, etc.)
---------------------------------------------------------------------------
INSERT INTO services (id, name, type, latitude, longitude, rating) VALUES
                                                                       (1, 'Central Park', 'PARK', 40.785091, -73.968285, 4.7),
                                                                       (2, 'Happy Paws Vet', 'VET', 40.712776, -74.005974, 4.5);

---------------------------------------------------------------------------
-- 6. Events
---------------------------------------------------------------------------
INSERT INTO events (
    id, title, description, event_date_time, location, host_id
) VALUES
      (1, 'Morning Dog Walk', 'Meet for a casual walk',
       TIMESTAMP '2025-05-29 09:00:00',
       ST_GeogFromText('SRID=4326;POINT(-0.1257 51.5085)'), 1),
      (2, 'Evening Park Meetup', 'Playtime in the park',
       TIMESTAMP '2025-05-30 18:00:00',
       ST_GeogFromText('SRID=4326;POINT(-0.1350 51.5099)'), 2);

INSERT INTO event_participants (event_id, user_id, status) VALUES
    (1, 1, 'GOING'),
    (2, 2, 'GOING');

---------------------------------------------------------------------------
-- 7. Chat / messages
---------------------------------------------------------------------------
INSERT INTO chats (id, type, event_id) VALUES (1, 'PRIVATE', NULL);

INSERT INTO chat_participants (chat_id, user_id) VALUES
                                                     (1, 1), (1, 2);

INSERT INTO messages (id, content, timestamp, chat_id, sender_id) VALUES
                                                                      (1, 'Hey Bob, how are you?',         TIMESTAMP '2025-05-28 09:10:00', 1, 1),
                                                                      (2, 'I''m good, thanks Alice!',      TIMESTAMP '2025-05-28 09:12:00', 1, 2);

---------------------------------------------------------------------------
-- 8. Matches / swipes
---------------------------------------------------------------------------
INSERT INTO matches (id, user1_id, user2_id, created_at) VALUES
    (1, 1, 2, TIMESTAMP '2025-05-28 09:15:00');

INSERT INTO swipes (id, liker_id, target_id, decision, created_at) VALUES
    (1, 1, 2, 'LIKE', TIMESTAMP '2025-05-28 09:20:00');

---------------------------------------------------------------------------
-- 9. Payments
---------------------------------------------------------------------------
INSERT INTO payments (
    id, amount, currency, status, timestamp, user_id
) VALUES
      (1, 49.99, 'USD', 'PAID',     TIMESTAMP '2025-05-28 09:25:00', 1),
      (2, 19.99, 'USD', 'REFUNDED', TIMESTAMP '2025-05-28 09:30:00', 2);

-- ---------------------------------------------------
-- End V3 (manual-testing data)

-- V3__seed_manual_test_data.sql
-- Expanded fixture data for local / CI environments ONLY.
-- Assumes reference data from V2__seed_reference_data.sql already present.
-- ---------------------------------------------------------------------------
-- NOTE:   NEVER run this script in production.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 1. Users (IDs 3‑35)
-- ---------------------------------------------------------------------------
INSERT INTO users (
    id, username, email, password_hash, bio, birthdate, gender,
    location, location_visible, profile_photo_url, created_at
) VALUES
      (3, 'charlie',  'charlie@example.com',  '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Tri‑lingual traveller', DATE '1992-02-11', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(-3.7038 40.4168)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 10:00:00'),
      (4, 'diana',    'diana@example.com',    '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Runner and coffee lover', DATE '1994-08-23', 'FEMALE',
       ST_GeogFromText('SRID=4326;POINT(2.3522 48.8566)'),  TRUE, 'placeholder/PlaceholderUser.webp',   TIMESTAMP '2025-05-28 10:05:00'),
      (5, 'elliot',   'elliot@example.com',   '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Tech geek', DATE '1988-12-05', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(-74.0060 40.7128)'), TRUE, 'placeholder/PlaceholderUser.webp',  TIMESTAMP '2025-05-28 10:10:00'),
      (6, 'fatima',   'fatima@example.com',   '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Love yoga & dogs', DATE '1996-05-17', 'FEMALE',
       ST_GeogFromText('SRID=4326;POINT(55.2708 25.2048)'), TRUE, 'placeholder/PlaceholderUser.webp',  TIMESTAMP '2025-05-28 10:15:00'),
      (7, 'george',   'george@example.com',   '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Outdoor enthusiast', DATE '1983-11-30', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(151.2093 -33.8688)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 10:20:00'),
      (8, 'hana',     'hana@example.com',     '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Plant mum 🌱', DATE '1991-03-12', 'FEMALE',
       ST_GeogFromText('SRID=4326;POINT(139.6917 35.6895)'), TRUE, 'placeholder/PlaceholderUser.webp',    TIMESTAMP '2025-05-28 10:25:00'),
      (9, 'igor',     'igor@example.com',     '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Cyclist', DATE '1987-07-07', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(30.5234 50.4501)'), TRUE, 'placeholder/PlaceholderUser.webp',     TIMESTAMP '2025-05-28 10:30:00'),
      (10,'julia',    'julia@example.com',    '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Food blogger', DATE '1995-09-09', 'FEMALE',
       ST_GeogFromText('SRID=4326;POINT(-118.2437 34.0522)'), TRUE, 'placeholder/PlaceholderUser.webp',  TIMESTAMP '2025-05-28 10:35:00'),
      (11,'kai',      'kai@example.com',      '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Gamer & streamer', DATE '1999-01-20', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(103.8198 1.3521)'), TRUE, 'placeholder/PlaceholderUser.webp',      TIMESTAMP '2025-05-28 10:40:00'),
      (12,'linda',    'linda@example.com',    '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Artist 🎨', DATE '1982-04-18', 'FEMALE',
       ST_GeogFromText('SRID=4326;POINT(-0.118092 51.509865)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 10:45:00'),

      (13,'mike',     'mike@example.com',     '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Coffee addict', DATE '1990-11-11', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(-0.1200 51.5080)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 10:50:00'),
      (14,'nina',     'nina@example.com',     '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'Dog photographer', DATE '1993-02-02', 'FEMALE',
       ST_GeogFromText('SRID=4326;POINT(-0.1215 51.5085)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 10:55:00'),
      (15,'owen',     'owen@example.com',     '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi',
       'History buff', DATE '1989-07-07', 'MALE',
       ST_GeogFromText('SRID=4326;POINT(-0.1225 51.5090)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 11:00:00'),
      (16, 'paula', 'paula@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Paula', DATE '1986-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1300 51.5000)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:00:00'),
      (17, 'quentin', 'quentin@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Quentin', DATE '1987-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1310 51.5010)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:01:00'),
      (18, 'rachel', 'rachel@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Rachel', DATE '1988-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1320 51.5020)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:02:00'),
      (19, 'sam', 'sam@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Sam', DATE '1989-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1330 51.5030)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:03:00'),
      (20, 'tina', 'tina@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Tina', DATE '1990-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1340 51.5040)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:04:00'),
      (21, 'ursula', 'ursula@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Ursula', DATE '1991-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1350 51.5050)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:05:00'),
      (22, 'victor', 'victor@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Victor', DATE '1992-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1360 51.5060)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:06:00'),
      (23, 'wendy', 'wendy@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Wendy', DATE '1993-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1370 51.5070)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:07:00'),
      (24, 'xavier', 'xavier@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Xavier', DATE '1994-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1380 51.5080)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:08:00'),
      (25, 'yara', 'yara@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Yara', DATE '1995-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1390 51.5090)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:09:00'),
      (26, 'zack', 'zack@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Zack', DATE '1996-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1400 51.5100)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:10:00'),
      (27, 'abby', 'abby@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Abby', DATE '1997-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1410 51.5110)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:11:00'),
      (28, 'brad', 'brad@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Brad', DATE '1998-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1420 51.5120)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:12:00'),
      (29, 'carmen', 'carmen@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Carmen', DATE '1999-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1430 51.5130)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:13:00'),
      (30, 'dan', 'dan@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Dan', DATE '2000-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1440 51.5140)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:14:00'),
      (31, 'ella', 'ella@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Ella', DATE '2001-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1450 51.5150)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:15:00'),
      (32, 'frank', 'frank@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Frank', DATE '2002-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1460 51.5160)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:16:00'),
      (33, 'grace', 'grace@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Grace', DATE '2003-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1470 51.5170)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:17:00'),
      (34, 'hugo', 'hugo@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Hugo', DATE '2004-01-01', 'FEMALE', ST_GeogFromText('SRID=4326;POINT(-0.1480 51.5180)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:18:00'),
      (35, 'iris', 'iris@example.com', '$2a$10$eUfPhw9OpHsVIH44NcRHyufdMuAyAT9yg/ZO3MvW4kAyqCQVaZ6Xi', 'Bio for Iris', DATE '2005-01-01', 'MALE', ST_GeogFromText('SRID=4326;POINT(-0.1490 51.5190)'), TRUE, 'placeholder/PlaceholderUser.webp', TIMESTAMP '2025-05-28 12:19:00');

-- ---------------------------------------------------------------------------
-- 2. User ↔ Role  (all regular users except Elliot is premium)
-- ---------------------------------------------------------------------------
INSERT INTO user_roles (user_id, role_id) VALUES
                                              (3, 1),
                                              (4, 1),
                                              (5, 1), (5, 2),  -- Elliot also premium
                                              (6, 1),
                                              (7, 1),
                                              (8, 1),
                                              (9, 1),
                                              (10,1),
                                              (11,1),
                                              (12,1),
                                              (13,1),
                                             (14,1),
                                             (15,1),
                                             (16,1),
                                             (17,1),
                                             (18,1),
                                             (19,1),
                                             (20,1),
                                             (21,1),
                                             (22,1),
                                             (23,1),
                                             (24,1),
                                             (25,1),
                                             (26,1),
                                             (27,1),
                                             (28,1),
                                             (29,1),
                                             (30,1),
                                             (31,1),
                                             (32,1),
                                             (33,1),
                                             (34,1),
                                             (35,1);

-- ---------------------------------------------------------------------------
-- 3. User ↔ Languages
-- ---------------------------------------------------------------------------
INSERT INTO user_languages (user_id, language_id) VALUES
                                                      (3, 1), (3, 2),
                                                      (4, 1), (4, 3),
                                                      (5, 1),
                                                      (6, 1), (6, 2),
                                                      (7, 1),
                                                      (8, 1), (8, 3),
                                                      (9, 1),
                                                      (10,1), (10,2),
                                                      (11,1), (11,2), (11,3),
                                                      (12,1),
                                                      (13,1),
                                                      (14,1),
                                                      (15,1),
                                                      (16,1),
                                                      (17,1),
                                                      (18,1),
                                                      (19,1),
                                                      (20,1),
                                                      (21,1),
                                                      (22,1),
                                                      (23,1),
                                                      (24,1),
                                                      (25,1),
                                                      (26,1),
                                                      (27,1),
                                                      (28,1),
                                                      (29,1),
                                                      (30,1),
                                                      (31,1),
                                                      (32,1),
                                                      (33,1),
                                                      (34,1),
                                                      (35,1);

-- ---------------------------------------------------------------------------
-- 4. Preferences
-- ---------------------------------------------------------------------------
INSERT INTO preferences (
    user_id, preferred_personality, preferred_activity_level, preferred_size, preferred_gender
) VALUES
      (3,  'FRIENDLY', 'MEDIUM', 'MEDIUM', 'FEMALE'),
      (4,  'CALM',     'LOW',    'SMALL',  'MALE'),
      (5,  'PLAYFUL',  'HIGH',   'LARGE',  'FEMALE'),
      (6,  'FRIENDLY', 'LOW',    'MEDIUM', 'MALE'),
      (7,  'CALM',     'HIGH',   'LARGE',  'FEMALE'),
      (8,  'PLAYFUL',  'MEDIUM', 'SMALL',  'FEMALE'),
      (9,  'FRIENDLY', 'HIGH',   'MEDIUM', 'FEMALE'),
      (10, 'CALM',     'LOW',    'SMALL',  'MALE'),
      (11, 'PLAYFUL',  'HIGH',   'LARGE',  'FEMALE'),
      (12, 'FRIENDLY', 'MEDIUM', 'MEDIUM', 'MALE'),
      (13, 'CALM',     'LOW',    'SMALL',  'FEMALE'),
      (14, 'FRIENDLY', 'HIGH',   'MEDIUM', 'MALE'),
      (15, 'PLAYFUL',  'MEDIUM', 'MEDIUM', 'FEMALE'),
      (16, 'FRIENDLY', 'MEDIUM', 'MEDIUM', 'FEMALE'),
      (17, 'CALM', 'LOW', 'SMALL', 'MALE'),
      (18, 'PLAYFUL', 'HIGH', 'LARGE', 'FEMALE'),
      (19, 'FRIENDLY', 'LOW', 'MEDIUM', 'MALE'),
      (20, 'FRIENDLY', 'MEDIUM', 'MEDIUM', 'FEMALE'),
      (21, 'CALM', 'LOW', 'SMALL', 'MALE'),
      (22, 'PLAYFUL', 'HIGH', 'LARGE', 'FEMALE'),
      (23, 'FRIENDLY', 'LOW', 'MEDIUM', 'MALE'),
      (24, 'FRIENDLY', 'MEDIUM', 'MEDIUM', 'FEMALE'),
      (25, 'CALM', 'LOW', 'SMALL', 'MALE'),
      (26, 'PLAYFUL', 'HIGH', 'LARGE', 'FEMALE'),
      (27, 'FRIENDLY', 'LOW', 'MEDIUM', 'MALE'),
      (28, 'FRIENDLY', 'MEDIUM', 'MEDIUM', 'FEMALE'),
      (29, 'CALM', 'LOW', 'SMALL', 'MALE'),
      (30, 'PLAYFUL', 'HIGH', 'LARGE', 'FEMALE'),
      (31, 'FRIENDLY', 'LOW', 'MEDIUM', 'MALE'),
      (32, 'FRIENDLY', 'MEDIUM', 'MEDIUM', 'FEMALE'),
      (33, 'CALM', 'LOW', 'SMALL', 'MALE'),
      (34, 'PLAYFUL', 'HIGH', 'LARGE', 'FEMALE'),
      (35, 'FRIENDLY', 'LOW', 'MEDIUM', 'MALE');

-- ---------------------------------------------------------------------------
-- 5. Dogs  (IDs 3‑41)
--      Each user owns 1‑3 dogs to cover edge‑cases.
-- ---------------------------------------------------------------------------
INSERT INTO dogs (
    id, name, breed, birthdate, size, gender, personality, activity_level, about, owner_id
) VALUES
      (3,  'Bailey', 'Golden Retriever', DATE '2019-04-14', 'LARGE',  'FEMALE', 'FRIENDLY', 'HIGH',   'Loves fetch',               3),
      (4,  'Milo',   'Pug',             DATE '2021-11-01', 'SMALL',  'MALE',   'CALM',     'LOW',    'Nap expert',                4),
      (5,  'Nala',   'Border Collie',   DATE '2017-01-20', 'MEDIUM', 'FEMALE', 'PLAYFUL',  'HIGH',   'Agility champ',             5),
      (6,  'Oscar',  'Dachshund',       DATE '2022-03-05', 'SMALL',  'MALE',   'FRIENDLY', 'MEDIUM', 'Sausage sprint star',       6),
      (7,  'Poppy',  'Shiba Inu',       DATE '2020-07-30', 'MEDIUM', 'FEMALE', 'CALM',     'MEDIUM', 'Independent thinker',       7),
      (8,  'Quincy', 'Great Dane',      DATE '2018-12-12', 'LARGE',  'MALE',   'CALM',     'LOW',    'Gentle giant',              7),
      (9,  'Ruby',   'Corgi',           DATE '2019-05-17', 'SMALL',  'FEMALE', 'PLAYFUL',  'HIGH',   'Zoomies queen',             8),
      (10, 'Sasha',  'Samoyed',         DATE '2018-09-09', 'MEDIUM', 'FEMALE', 'FRIENDLY', 'HIGH',   'Smiling fluff',             8),
      (11, 'Toby',   'Whippet',         DATE '2021-02-14', 'MEDIUM', 'MALE',   'PLAYFUL',  'HIGH',   'Sprint addict',             9),
      (12, 'Uma',    'French Bulldog',  DATE '2023-01-07', 'SMALL',  'FEMALE', 'CALM',     'LOW',    'Snuggle buddy',             9),
      (13, 'Veda',   'German Shepherd', DATE '2016-10-02', 'LARGE',  'FEMALE', 'FRIENDLY', 'MEDIUM', 'Very loyal',                10),
      (14, 'Wally',  'Basset Hound',    DATE '2015-06-18', 'MEDIUM', 'MALE',   'CALM',     'LOW',    'Loves treats',             10),
      (15, 'Xena',   'Husky',           DATE '2019-12-24', 'MEDIUM', 'FEMALE', 'PLAYFUL',  'HIGH',   'Howls on command',          10),
      (16, 'Yoshi',  'Akita',           DATE '2022-04-03', 'LARGE',  'MALE',   'CALM',     'LOW',    'Very dignified',            11),
      (17, 'Zara',   'Maltese',         DATE '2020-08-01', 'SMALL',  'FEMALE', 'FRIENDLY', 'LOW',    'Lap dog deluxe',           12),
      (18, 'Ajax',   'Boxer',           DATE '2017-07-11', 'MEDIUM', 'MALE',   'PLAYFUL',  'HIGH',   'Energetic guardian',       12),
      (19, 'Bella',  'Cocker Spaniel',  DATE '2021-05-05', 'MEDIUM', 'FEMALE', 'FRIENDLY', 'MEDIUM', 'Loves cuddles',           13),
      (20, 'Coco',   'Poodle',          DATE '2019-10-10', 'SMALL',  'FEMALE', 'PLAYFUL',  'HIGH',   'Tricks expert',           14),
      (21, 'Duke',   'Bulldog',         DATE '2018-01-15', 'MEDIUM', 'MALE',   'CALM',     'LOW',    'Gentle soul',              15),
      (22, 'Ace', 'Dalmatian', DATE '2021-01-01', 'MEDIUM', 'MALE', 'PLAYFUL', 'HIGH', 'About Ace', 16),
      (23, 'Buddy', 'Terrier', DATE '2021-01-02', 'SMALL', 'FEMALE', 'PLAYFUL', 'MEDIUM', 'About Buddy', 17),
      (24, 'Cleo', 'Shepherd', DATE '2021-01-03', 'LARGE', 'MALE', 'FRIENDLY', 'HIGH', 'About Cleo', 18),
      (25, 'Daisy', 'Spaniel', DATE '2021-01-04', 'MEDIUM', 'FEMALE', 'PLAYFUL', 'MEDIUM', 'About Daisy', 19),
      (26, 'Echo', 'Beagle', DATE '2021-01-05', 'SMALL', 'MALE', 'PLAYFUL', 'HIGH', 'About Echo', 20),
      (27, 'Fido', 'Collie', DATE '2021-01-06', 'MEDIUM', 'FEMALE', 'FRIENDLY', 'MEDIUM', 'About Fido', 21),
      (28, 'Gigi', 'Boxer', DATE '2021-01-07', 'LARGE', 'MALE', 'PLAYFUL', 'HIGH', 'About Gigi', 22),
      (29, 'Hazel', 'Retriever', DATE '2021-01-08', 'MEDIUM', 'FEMALE', 'PLAYFUL', 'MEDIUM', 'About Hazel', 23),
      (30, 'Indy', 'Poodle', DATE '2021-01-09', 'SMALL', 'MALE', 'FRIENDLY', 'HIGH', 'About Indy', 24),
      (31, 'Jax', 'Bulldog', DATE '2021-01-10', 'MEDIUM', 'FEMALE', 'PLAYFUL', 'MEDIUM', 'About Jax', 25),
      (32, 'Koda', 'Husky', DATE '2021-01-11', 'LARGE', 'MALE', 'PLAYFUL', 'HIGH', 'About Koda', 26),
      (33, 'Luna', 'Mastiff', DATE '2021-01-12', 'LARGE', 'FEMALE', 'FRIENDLY', 'MEDIUM', 'About Luna', 27),
      (34, 'Milo2', 'Pug', DATE '2021-01-13', 'SMALL', 'MALE', 'PLAYFUL', 'HIGH', 'About Milo2', 28),
      (35, 'Nora', 'Pointer', DATE '2021-01-14', 'MEDIUM', 'FEMALE', 'PLAYFUL', 'MEDIUM', 'About Nora', 29),
      (36, 'Ollie', 'Ridgeback', DATE '2021-01-15', 'LARGE', 'MALE', 'FRIENDLY', 'HIGH', 'About Ollie', 30),
      (37, 'Piper', 'Shiba', DATE '2021-01-16', 'SMALL', 'FEMALE', 'PLAYFUL', 'MEDIUM', 'About Piper', 31),
      (38, 'Quinn', 'Chow', DATE '2021-01-17', 'MEDIUM', 'MALE', 'PLAYFUL', 'HIGH', 'About Quinn', 32),
      (39, 'Rosie', 'Corgi', DATE '2021-01-18', 'SMALL', 'FEMALE', 'FRIENDLY', 'MEDIUM', 'About Rosie', 33),
      (40, 'Scout', 'Akita', DATE '2021-01-19', 'LARGE', 'MALE', 'PLAYFUL', 'HIGH', 'About Scout', 34),
      (41, 'Toby2', 'Labrador', DATE '2021-01-20', 'MEDIUM', 'FEMALE', 'PLAYFUL', 'MEDIUM', 'About Toby2', 35);
-- ---------------------------------------------------------------------------
INSERT INTO dog_photo_urls (dog_id, photo_urls) VALUES
  (3, 'placeholder/DogPlaceholder1.webp'),
  (3, 'placeholder/DogPlaceholder2.webp'),
  (4, 'placeholder/DogPlaceholder1.webp'),
  (4, 'placeholder/DogPlaceholder2.webp'),
  (5, 'placeholder/DogPlaceholder1.webp'),
  (5, 'placeholder/DogPlaceholder2.webp'),
  (6, 'placeholder/DogPlaceholder1.webp'),
  (6, 'placeholder/DogPlaceholder2.webp'),
  (7, 'placeholder/DogPlaceholder1.webp'),
  (7, 'placeholder/DogPlaceholder2.webp'),
  (8, 'placeholder/DogPlaceholder1.webp'),
  (8, 'placeholder/DogPlaceholder2.webp'),
  (9, 'placeholder/DogPlaceholder1.webp'),
  (9, 'placeholder/DogPlaceholder2.webp'),
  (10, 'placeholder/DogPlaceholder1.webp'),
  (10, 'placeholder/DogPlaceholder2.webp'),
  (11, 'placeholder/DogPlaceholder1.webp'),
  (11, 'placeholder/DogPlaceholder2.webp'),
  (12, 'placeholder/DogPlaceholder1.webp'),
  (12, 'placeholder/DogPlaceholder2.webp'),
  (13, 'placeholder/DogPlaceholder1.webp'),
  (13, 'placeholder/DogPlaceholder2.webp'),
  (14, 'placeholder/DogPlaceholder1.webp'),
  (14, 'placeholder/DogPlaceholder2.webp'),
  (15, 'placeholder/DogPlaceholder1.webp'),
  (15, 'placeholder/DogPlaceholder2.webp'),
  (16, 'placeholder/DogPlaceholder1.webp'),
  (16, 'placeholder/DogPlaceholder2.webp'),
  (17, 'placeholder/DogPlaceholder1.webp'),
  (17, 'placeholder/DogPlaceholder2.webp'),
  (18, 'placeholder/DogPlaceholder1.webp'),
  (18, 'placeholder/DogPlaceholder2.webp'),
  (19, 'placeholder/DogPlaceholder1.webp'),
  (19, 'placeholder/DogPlaceholder2.webp'),
  (20, 'placeholder/DogPlaceholder1.webp'),
  (20, 'placeholder/DogPlaceholder2.webp'),
  (21, 'placeholder/DogPlaceholder1.webp'),
  (21, 'placeholder/DogPlaceholder2.webp'),
  (22, 'placeholder/DogPlaceholder1.webp'),
  (22, 'placeholder/DogPlaceholder2.webp'),
  (23, 'placeholder/DogPlaceholder1.webp'),
  (23, 'placeholder/DogPlaceholder2.webp'),
  (24, 'placeholder/DogPlaceholder1.webp'),
  (24, 'placeholder/DogPlaceholder2.webp'),
  (25, 'placeholder/DogPlaceholder1.webp'),
  (25, 'placeholder/DogPlaceholder2.webp'),
  (26, 'placeholder/DogPlaceholder1.webp'),
  (26, 'placeholder/DogPlaceholder2.webp'),
  (27, 'placeholder/DogPlaceholder1.webp'),
  (27, 'placeholder/DogPlaceholder2.webp'),
  (28, 'placeholder/DogPlaceholder1.webp'),
  (28, 'placeholder/DogPlaceholder2.webp'),
  (29, 'placeholder/DogPlaceholder1.webp'),
  (29, 'placeholder/DogPlaceholder2.webp'),
  (30, 'placeholder/DogPlaceholder1.webp'),
  (30, 'placeholder/DogPlaceholder2.webp'),
  (31, 'placeholder/DogPlaceholder1.webp'),
  (31, 'placeholder/DogPlaceholder2.webp'),
  (32, 'placeholder/DogPlaceholder1.webp'),
  (32, 'placeholder/DogPlaceholder2.webp'),
  (33, 'placeholder/DogPlaceholder1.webp'),
  (33, 'placeholder/DogPlaceholder2.webp'),
  (34, 'placeholder/DogPlaceholder1.webp'),
  (34, 'placeholder/DogPlaceholder2.webp'),
  (35, 'placeholder/DogPlaceholder1.webp'),
  (35, 'placeholder/DogPlaceholder2.webp'),
  (36, 'placeholder/DogPlaceholder1.webp'),
  (36, 'placeholder/DogPlaceholder2.webp'),
  (37, 'placeholder/DogPlaceholder1.webp'),
  (37, 'placeholder/DogPlaceholder2.webp'),
  (38, 'placeholder/DogPlaceholder1.webp'),
  (38, 'placeholder/DogPlaceholder2.webp'),
  (39, 'placeholder/DogPlaceholder1.webp'),
  (39, 'placeholder/DogPlaceholder2.webp'),
  (40, 'placeholder/DogPlaceholder1.webp'),
  (40, 'placeholder/DogPlaceholder2.webp'),
  (41, 'placeholder/DogPlaceholder1.webp'),
  (41, 'placeholder/DogPlaceholder2.webp');
-- 6. Services  (add a few more)
-- ---------------------------------------------------------------------------
INSERT INTO services (id, name, type, latitude, longitude, rating) VALUES
                                                                       (3, 'Doggo Groom Salon', 'GROOMER', 51.5155, -0.1420, 4.6),
                                                                       (4, 'Happy Trails Park', 'PARK',    34.0522, -118.2437, 4.8);

---------------------------------------------------------------------------
-- 7. Events
---------------------------------------------------------------------------
INSERT INTO events (
    id, title, description, event_date_time, location, host_id
) VALUES
      (3, 'City Paws Tour', 'Explore the city with our dogs',
       TIMESTAMP '2025-06-01 10:00:00',
       ST_GeogFromText('SRID=4326;POINT(-3.7038 40.4168)'), 3),
      (4, 'Techies Dog Meetup', 'Hangout for tech enthusiasts and pets',
       TIMESTAMP '2025-06-05 14:00:00',
       ST_GeogFromText('SRID=4326;POINT(-74.0060 40.7128)'), 5),
      (5, 'Coastal Run', 'Morning run by the coast',
       TIMESTAMP '2025-06-10 08:30:00',
       ST_GeogFromText('SRID=4326;POINT(151.2093 -33.8688)'), 7);

INSERT INTO event_participants (event_id, user_id, status) VALUES
    (3, 3, 'GOING'),
    (3, 4, 'INTERESTED'),
    (4, 5, 'GOING'),
    (5, 7, 'GOING'),
    (5, 8, 'INTERESTED');

---------------------------------------------------------------------------
-- 8. Chats & Messages
---------------------------------------------------------------------------
INSERT INTO chats (id, type, event_id) VALUES
                                           (2, 'PRIVATE', NULL),
                                           (3, 'PRIVATE', NULL),
                                           (4, 'GROUP',   NULL),
                                           (5, 'PRIVATE', NULL),
                                           (6, 'PRIVATE', NULL);

INSERT INTO chat_participants (chat_id, user_id) VALUES
                                                     (2, 3), (2, 4),
                                                     (3, 5), (3, 6),
                                                     (4, 7), (4, 8), (4, 9),
                                                     (5, 7), (5, 8),
                                                     (6, 9), (6, 10);

INSERT INTO messages (id, content, timestamp, chat_id, sender_id) VALUES
                                                                      (3, 'Hola Diana!',                    TIMESTAMP '2025-05-28 11:00:00', 2, 3),
                                                                      (4, 'Hey Charlie, ¿qué tal?',        TIMESTAMP '2025-05-28 11:01:00', 2, 4),
                                                                      (5, 'Let’s plan a play date',        TIMESTAMP '2025-05-28 11:05:00', 3, 5),
                                                                      (6, 'Sounds good — park at 6pm?',    TIMESTAMP '2025-05-28 11:06:00', 3, 6),
                                                                      (7, 'Anyone up for a hike Sunday?',  TIMESTAMP '2025-05-28 11:10:00', 4, 7),
                                                                      (8, 'Hey Hana, want to walk our dogs this weekend?', TIMESTAMP '2025-05-28 11:32:00', 5, 7),
                                                                      (9, 'Sure George, let''s meet at the park.',         TIMESTAMP '2025-05-28 11:33:00', 5, 8);
---------------------------------------------------------------------------
-- 9. Matches & Swipes
---------------------------------------------------------------------------
INSERT INTO matches (id, user1_id, user2_id, created_at) VALUES
                                                             (2, 3, 4, TIMESTAMP '2025-05-28 11:15:00'),
                                                             (3, 5, 6, TIMESTAMP '2025-05-28 11:20:00'),
                                                             (4, 7, 8, TIMESTAMP '2025-05-28 11:30:00'),
                                                             (5, 9, 10, TIMESTAMP '2025-05-28 11:40:00');

INSERT INTO swipes (id, liker_id, target_id, decision, created_at) VALUES
                                                                       (2, 3, 4, 'LIKE', TIMESTAMP '2025-05-28 11:14:00'),
                                                                       (3, 4, 3, 'LIKE', TIMESTAMP '2025-05-28 11:14:30'),
                                                                       (4, 5, 6, 'LIKE', TIMESTAMP '2025-05-28 11:19:00'),
                                                                       (5, 6, 5, 'LIKE', TIMESTAMP '2025-05-28 11:19:20'),
                                                                       (6, 7, 8, 'LIKE', TIMESTAMP '2025-05-28 11:29:00'),
                                                                       (7, 8, 7, 'LIKE', TIMESTAMP '2025-05-28 11:29:30'),
                                                                       (8, 9, 10, 'LIKE', TIMESTAMP '2025-05-28 11:39:00'),
                                                                       (9, 10, 9, 'LIKE', TIMESTAMP '2025-05-28 11:39:20');

-- ---------------------------------------------------------------------------
-- 10. Payments  (Premium & test payments)
-- ---------------------------------------------------------------------------
INSERT INTO payments (id, amount, currency, status, timestamp, user_id) VALUES
                                                                            (3, 9.99, 'USD', 'PAID',     TIMESTAMP '2025-05-28 11:25:00', 5),  -- Elliot monthly premium
                                                                            (4, 49.99, 'USD', 'PAID',    TIMESTAMP '2025-05-28 11:26:00', 10);

-- ---------------------------------------------------------------------------
-- 11. Sequence synchronisation
-- ---------------------------------------------------------------------------
SELECT setval('users_id_seq',     (SELECT MAX(id) FROM users));
SELECT setval('dogs_id_seq',      (SELECT MAX(id) FROM dogs));
SELECT setval('services_id_seq',  (SELECT MAX(id) FROM services));
SELECT setval('chats_id_seq',     (SELECT MAX(id) FROM chats));
SELECT setval('events_id_seq',  (SELECT MAX(id) FROM events));
SELECT setval('messages_id_seq',  (SELECT MAX(id) FROM messages));
SELECT setval('matches_id_seq',   (SELECT MAX(id) FROM matches));
SELECT setval('swipes_id_seq',    (SELECT MAX(id) FROM swipes));
SELECT setval('payments_id_seq',  (SELECT MAX(id) FROM payments));

-- ---------------------------------------------------------------------------
-- End V3 (manual‑testing data)
-- ---------------------------------------------------------------------------
