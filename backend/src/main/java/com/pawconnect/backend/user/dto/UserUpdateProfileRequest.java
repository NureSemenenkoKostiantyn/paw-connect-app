package com.pawconnect.backend.user.dto;

import com.pawconnect.backend.user.model.UserGender;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.time.LocalDate;
import java.util.Set;

@Data
public class UserUpdateProfileRequest {

    @Size(max = 500, message = "Bio cannot exceed 500 characters")
    private String bio;

    @Past(message = "Birthdate must be in the past")
    private LocalDate birthdate;

    private UserGender gender;

    @DecimalMin(value = "-90.0", message = "Latitude must be between -90 and 90")
    @DecimalMax(value = "90.0", message = "Latitude must be between -90 and 90")
    private Double latitude;

    @DecimalMin(value = "-180.0", message = "Longitude must be between -180 and 180")
    @DecimalMax(value = "180.0", message = "Longitude must be between -180 and 180")
    private Double longitude;

    private Boolean locationVisible;

    @Size(max = 10, message = "You can select up to 10 languages")
    private Set<@Positive(message = "Language ID must be positive") Long> languageIds;
}