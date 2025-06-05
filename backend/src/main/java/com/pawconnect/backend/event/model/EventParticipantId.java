package com.pawconnect.backend.event.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EventParticipantId implements Serializable {
    private Long event;
    private Long user;
}