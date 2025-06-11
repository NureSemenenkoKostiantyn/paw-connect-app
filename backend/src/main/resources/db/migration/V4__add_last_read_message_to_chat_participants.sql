ALTER TABLE chat_participants
    ADD COLUMN last_read_message_id BIGINT;

ALTER TABLE chat_participants
    ADD CONSTRAINT fk_chat_participants_last_read_message
        FOREIGN KEY (last_read_message_id)
            REFERENCES messages(id);
