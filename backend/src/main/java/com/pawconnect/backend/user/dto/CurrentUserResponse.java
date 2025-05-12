package com.pawconnect.backend.user.dto;

import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.user.model.UserGender;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

@Data
public class CurrentUserResponse {
    private Long id;
    private String username;
    private String email;
    private String bio;
    private LocalDate birthdate;
    private UserGender gender;
    private double latitude;
    private double longitude;
    private Boolean locationVisible;
    private String profilePhotoUrl;
    private Set<String> languages;
    private List<DogResponse> dogs;
}
