package com.pawconnect.backend.match.dto;

import com.pawconnect.backend.dog.dto.DogResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CandidateUserResponse {
    private Long userId;
    private String userName;
    private List<DogResponse> dog;
    private List<String> photoUrls;
    private Double distanceKm;
    private Integer compatibilityScore;
}