package com.pawconnect.backend.user.dto;

import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.user.model.UserGender;
import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class PublicUserResponse {
    private Long id;
    private String username;
    private String bio;
    private Integer age;
    private UserGender gender;
    private String profilePhotoUrl;
    private Set<String> languages;
    private List<DogResponse> dogs;
}
