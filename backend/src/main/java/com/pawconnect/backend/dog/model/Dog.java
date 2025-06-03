package com.pawconnect.backend.dog.model;
import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDate;
import java.util.List;


@Entity
@Table(name = "dogs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Dog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String name;

    @NotBlank
    private String breed;

    @NotNull
    private LocalDate birthdate;

    @Enumerated(EnumType.STRING)
    @NotNull
    private DogSize size;

    @Enumerated(EnumType.STRING)
    @NotNull
    private DogGender gender;

    @Enumerated(EnumType.STRING)
    @NotNull
    private Personality personality;

    @Enumerated(EnumType.STRING)
    @NotNull
    private ActivityLevel activityLevel;

    private String about;

    @ElementCollection
    private List<String> photoUrls;

    @ManyToOne
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

}
