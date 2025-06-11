-- V5__seed_last_read_message_ids.sql
-- Populate last_read_message_id for existing chat participants after column addition.

UPDATE chat_participants cp
SET last_read_message_id = sub.last_id
FROM (
    SELECT chat_id, MAX(id) AS last_id
    FROM messages
    GROUP BY chat_id
) sub
WHERE cp.chat_id = sub.chat_id;
