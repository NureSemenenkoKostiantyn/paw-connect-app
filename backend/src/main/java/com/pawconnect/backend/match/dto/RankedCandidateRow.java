package com.pawconnect.backend.match.dto;

public interface RankedCandidateRow {
    Long   getUser_id();
    Double getDistance_km();
    Integer getScore();
}