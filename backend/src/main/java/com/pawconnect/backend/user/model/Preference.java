package com.pawconnect.backend.user.model;

import com.pawconnect.backend.dog.model.ActivityLevel;
import com.pawconnect.backend.dog.model.DogGender;
import com.pawconnect.backend.dog.model.DogSize;
import com.pawconnect.backend.dog.model.Personality;
import lombok.*;
import jakarta.persistence.*;

@Entity
@Table(name = "preferences")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Preference {

    @Id
    private Long id;            // == user_id (shared PK)

    @OneToOne
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Enumerated(EnumType.STRING)
    private Personality preferredPersonality;

    @Enumerated(EnumType.STRING)
    private ActivityLevel preferredActivityLevel;

    @Enumerated(EnumType.STRING)
    private DogSize preferredSize;

    @Enumerated(EnumType.STRING)
    private DogGender preferredGender;
}
