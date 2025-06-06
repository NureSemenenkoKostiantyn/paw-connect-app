-- V5__index_event_location.sql
-- Add GIST index for fast spatial queries on events.location

-- Ensure columns exist before creating index
ALTER TABLE events
    ADD COLUMN IF NOT EXISTS location GEOGRAPHY(POINT,4326),
    ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW();

ALTER TABLE event_participants
    ADD COLUMN IF NOT EXISTS joined_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW();

-- Create GIST index on the location column
CREATE INDEX IF NOT EXISTS idx_events_location_gist
    ON events
    USING GIST (location);
