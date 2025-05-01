package com.pawconnect.backend.serviceplace.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "services")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Service {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String type; // Наприклад: PARK, VET, GROOMER

    private Double latitude;
    private Double longitude;

    private Double rating;
}
