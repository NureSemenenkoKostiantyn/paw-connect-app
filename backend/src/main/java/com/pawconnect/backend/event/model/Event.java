package com.pawconnect.backend.event.model;

import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "events")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String description;
    private LocalDateTime eventDateTime;

    private Double latitude;
    private Double longitude;

    private String visibility; // "PUBLIC" або "FRIENDS"

    @ManyToOne
    @JoinColumn(name = "host_id", nullable = false)
    private User host;

    @OneToMany(mappedBy = "event", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<EventParticipant> participants = new ArrayList<>();
}

