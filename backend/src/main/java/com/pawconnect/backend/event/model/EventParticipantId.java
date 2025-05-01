package com.pawconnect.backend.event.model;

import java.io.Serializable;
import java.util.Objects;

public class EventParticipantId implements Serializable {
    private Long event;
    private Long user;

    public EventParticipantId() {}

    public EventParticipantId(Long event, Long user) {
        this.event = event;
        this.user = user;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        EventParticipantId that = (EventParticipantId) o;
        return Objects.equals(event, that.event) && Objects.equals(user, that.user);
    }

    @Override
    public int hashCode() {
        return Objects.hash(event, user);
    }
}