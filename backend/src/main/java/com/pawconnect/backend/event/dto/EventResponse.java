package com.pawconnect.backend.event.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class EventResponse {
    private Long id;
    private String title;
    private String description;
    private LocalDateTime eventDateTime;
    private double latitude;
    private double longitude;
    private Long hostId;
    private List<Long> participantIds;
}
