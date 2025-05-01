package com.pawconnect.backend.match.model;
import com.pawconnect.backend.common.enums.SwipeDecision;
import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "swipes", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"liker_id", "target_id"})
})
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Swipe {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "liker_id", nullable = false)
    private User liker;

    @ManyToOne
    @JoinColumn(name = "target_id", nullable = false)
    private User target;

    @Enumerated(EnumType.STRING)
    private SwipeDecision decision; // LIKE, PASS

    private LocalDateTime timestamp = LocalDateTime.now();

}
