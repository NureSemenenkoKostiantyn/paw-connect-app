package com.pawconnect.backend.dog.dto;

import com.pawconnect.backend.dog.model.ActivityLevel;
import com.pawconnect.backend.dog.model.Gender;
import com.pawconnect.backend.dog.model.Personality;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class DogUpdateRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String breed;

    @NotNull
    private LocalDate birthdate;

    @NotBlank
    private String size;

    @NotNull
    private Gender gender;

    @NotNull
    private Personality personality;

    @NotNull
    private ActivityLevel activityLevel;

    private String about;
}