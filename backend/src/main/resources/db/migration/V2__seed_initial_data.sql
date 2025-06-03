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
                                           (3, 'DE', 'German');

-- 3. Keep the sequences in sync
SELECT setval('roles_id_seq',     (SELECT MAX(id) FROM roles));
SELECT setval('languages_id_seq', (SELECT MAX(id) FROM languages));

-- ------------------------------------------------------
-- End V2 (reference data only)
