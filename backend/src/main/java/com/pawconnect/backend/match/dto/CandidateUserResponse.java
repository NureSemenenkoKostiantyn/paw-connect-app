package com.pawconnect.backend.match.dto;

import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.user.model.UserGender;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CandidateUserResponse {
    private Long id;
    private String username;
    private String bio;
    private UserGender gender;
    private String profilePhotoUrl;
    private Double distanceKm;
    private Set<String> languages;
    private List<DogResponse> dogs;
}