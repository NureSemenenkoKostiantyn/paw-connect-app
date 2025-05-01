package com.pawconnect.backend.chat.model;

import java.io.Serializable;
import java.util.Objects;

public class ChatParticipantId implements Serializable {
    private Long chat;
    private Long user;

    public ChatParticipantId() {}

    public ChatParticipantId(Long chat, Long user) {
        this.chat = chat;
        this.user = user;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ChatParticipantId that = (ChatParticipantId) o;
        return Objects.equals(chat, that.chat) && Objects.equals(user, that.user);
    }

    @Override
    public int hashCode() {
        return Objects.hash(chat, user);
    }
}