package com.pawconnect.backend.dog.dto;

import java.time.LocalDate;
import java.util.List;

import com.pawconnect.backend.dog.model.ActivityLevel;
import com.pawconnect.backend.dog.model.Gender;
import com.pawconnect.backend.dog.model.Personality;
import lombok.Data;

@Data
public class DogResponse {

    private Long id;
    private String name;
    private String breed;
    private LocalDate birthdate;
    private String size;
    private Gender gender;
    private Personality personality;
    private ActivityLevel activityLevel;
    private String about;
    private List<String> photoUrls;
    private Long ownerId;
}
