package com.pawconnect.backend.event.model;

import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "event_participants")
@IdClass(EventParticipantId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventParticipant {

    @Id
    @ManyToOne
    @JoinColumn(name = "event_id")
    private Event event;

    @Id
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private String status; // GOING, INTERESTED
}
