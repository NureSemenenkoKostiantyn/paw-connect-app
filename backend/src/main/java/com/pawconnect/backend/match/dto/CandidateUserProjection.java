package com.pawconnect.backend.match.dto;

public interface CandidateUserProjection {
    Long getId();
    String getUsername();
    String getBio();
    String getProfilePhotoUrl();
    String getGender();
    Double getDistanceKm();
    String getLanguages(); // JSON string
    String getDogs();      // JSON string
}