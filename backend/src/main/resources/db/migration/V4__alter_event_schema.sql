-- V4__alter_event_schema.sql
-- Adjust events schema to use geospatial point and track timestamps

ALTER TABLE events
    DROP COLUMN IF EXISTS visibility,
    DROP COLUMN IF EXISTS latitude,
    DROP COLUMN IF EXISTS longitude,
    ADD COLUMN IF NOT EXISTS location GEOGRAPHY(POINT,4326),
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW();

ALTER TABLE event_participants
    ADD COLUMN IF NOT EXISTS joined_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW();
