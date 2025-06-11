-- V2__seed_reference_data.sql
-- Reference tables that must exist in every environment
-- ------------------------------------------------------

-- 1. Roles  (matches your ERole enum)
INSERT INTO roles (id, name) VALUES
                                 (1, 'ROLE_USER'),
                                 (2, 'ROLE_PREMIUM'),
                                 (3, 'ROLE_MODERATOR'),
                                 (4, 'ROLE_ADMIN');

-- 2. Languages
INSERT INTO languages (id, code, name) VALUES
                                           (1, 'EN', 'English'),
                                           (2, 'ES', 'Spanish'),
                                           (3, 'DE', 'German'),
                                           (4, 'FR', 'French'),
                                           (5, 'IT', 'Italian'),
                                           (6, 'PT', 'Portuguese'),
                                           (7, 'RU', 'Russian'),
                                           (8, 'ZH', 'Chinese'),
                                           (9, 'JA', 'Japanese'),
                                           (10, 'KO', 'Korean'),
                                           (11, 'AR', 'Arabic'),
                                           (12, 'HI', 'Hindi'),
                                           (13, 'BN', 'Bengali'),
                                           (14, 'UR', 'Urdu'),
                                           (15, 'PA', 'Punjabi'),
                                           (16, 'FA', 'Persian'),
                                           (17, 'TR', 'Turkish'),
                                           (18, 'PL', 'Polish'),
                                           (19, 'NL', 'Dutch'),
                                           (20, 'SV', 'Swedish'),
                                           (21, 'FI', 'Finnish'),
                                           (22, 'NO', 'Norwegian'),
                                           (23, 'DA', 'Danish'),
                                           (24, 'EL', 'Greek'),
                                           (25, 'HE', 'Hebrew'),
                                           (26, 'VI', 'Vietnamese'),
                                           (27, 'TH', 'Thai'),
                                           (28, 'ID', 'Indonesian'),
                                           (29, 'MS', 'Malay'),
                                           (30, 'TL', 'Tagalog'),
                                           (31, 'SW', 'Swahili'),
                                           (32, 'UK', 'Ukrainian'),
                                           (33, 'CS', 'Czech'),
                                           (34, 'HU', 'Hungarian'),
                                           (35, 'RO', 'Romanian'),
                                           (36, 'BG', 'Bulgarian'),
                                           (37, 'HR', 'Croatian'),
                                           (38, 'SR', 'Serbian'),
                                           (39, 'SK', 'Slovak'),
                                           (40, 'SL', 'Slovenian'),
                                           (41, 'ET', 'Estonian'),
                                           (42, 'LV', 'Latvian'),
                                           (43, 'LT', 'Lithuanian'),
                                           (44, 'IS', 'Icelandic'),
                                           (45, 'GA', 'Irish'),
                                           (46, 'MT', 'Maltese'),
                                           (47, 'KA', 'Georgian'),
                                           (48, 'HY', 'Armenian'),
                                           (49, 'AZ', 'Azerbaijani'),
                                           (50, 'SQ', 'Albanian'),
                                           (51, 'BS', 'Bosnian'),
                                           (52, 'MK', 'Macedonian');

-- 3. Keep the sequences in sync
SELECT setval('roles_id_seq',     (SELECT MAX(id) FROM roles));
SELECT setval('languages_id_seq', (SELECT MAX(id) FROM languages));

-- ------------------------------------------------------
-- End V2 (reference data only)
