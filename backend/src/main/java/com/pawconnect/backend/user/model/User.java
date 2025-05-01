package com.pawconnect.backend.user.model;

import com.pawconnect.backend.dog.model.Dog;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String email;

    private String passwordHash;

    private Boolean isPremium = false;

    private Double latitude;
    private Double longitude;

    private String language;

    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Dog> dogs = new ArrayList<>();
}
