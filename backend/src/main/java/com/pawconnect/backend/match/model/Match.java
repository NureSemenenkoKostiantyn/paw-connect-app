package com.pawconnect.backend.match.model;
import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;


@Entity
@Table(name = "matches")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Match {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user1_id", nullable = false)
    private User user1;

    @ManyToOne
    @JoinColumn(name = "user2_id", nullable = false)
    private User user2;

    private LocalDateTime createdAt = LocalDateTime.now();

}