package com.pawconnect.backend.event.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class EventCreateRequest {
    private String title;
    private String description;
    private LocalDateTime eventDateTime;
    private Double latitude;
    private Double longitude;
}
