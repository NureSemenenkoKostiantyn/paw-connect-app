package com.pawconnect.backend.user.dto;

import com.pawconnect.backend.dog.model.ActivityLevel;
import com.pawconnect.backend.dog.model.DogGender;
import com.pawconnect.backend.dog.model.DogSize;
import com.pawconnect.backend.dog.model.Personality;
import lombok.Data;

@Data
public class PreferenceUpdateRequest {
    private Personality preferredPersonality;
    private ActivityLevel preferredActivityLevel;
    private DogSize preferredSize;
    private DogGender preferredGender;
}
