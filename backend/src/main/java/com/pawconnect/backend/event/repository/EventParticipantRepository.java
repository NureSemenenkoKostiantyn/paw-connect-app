package com.pawconnect.backend.event.repository;

import com.pawconnect.backend.event.model.EventParticipant;
import com.pawconnect.backend.event.model.EventParticipantId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EventParticipantRepository extends JpaRepository<EventParticipant, EventParticipantId> {
    boolean existsByEventIdAndUserId(Long eventId, Long userId);

    void deleteByEventIdAndUserId(Long eventId, Long userId);
}
