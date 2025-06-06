package com.pawconnect.backend.event.dto;

import lombok.Data;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDateTime;

@Data
public class EventCreateRequest {
    @NotBlank
    private String title;

    @NotBlank
    private String description;

    @NotNull
    private LocalDateTime eventDateTime;

    @NotNull
    private Double latitude;

    @NotNull
    private Double longitude;
}
