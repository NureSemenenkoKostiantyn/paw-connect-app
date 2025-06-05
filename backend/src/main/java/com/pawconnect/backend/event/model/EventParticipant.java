package com.pawconnect.backend.event.model;

import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;
import jakarta.validation.constraints.NotNull;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "event_participants")
@IdClass(EventParticipantId.class)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EqualsAndHashCode(exclude = {"event", "user"})
@ToString(exclude = {"event", "user"})
public class EventParticipant {

    @Id
    @ManyToOne
    @JoinColumn(name = "event_id")
    @NotNull
    private Event event;

    @Id
    @ManyToOne
    @JoinColumn(name = "user_id")
    @NotNull
    private User user;

    @Enumerated(EnumType.STRING)
    private EventParticipantStatus status;

    @CreationTimestamp
    private LocalDateTime joinedAt;
}
