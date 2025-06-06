package com.pawconnect.backend.event.controller;

import com.pawconnect.backend.event.dto.EventCreateRequest;
import com.pawconnect.backend.event.dto.EventResponse;
import com.pawconnect.backend.event.model.EventParticipantStatus;
import com.pawconnect.backend.event.service.EventService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@RestController
@RequestMapping("/api/events")
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService;

    @PostMapping
    public ResponseEntity<EventResponse> createEvent(@Valid @RequestBody EventCreateRequest request) {
        EventResponse response = eventService.createEvent(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<EventResponse>> searchEvents(
            @RequestParam("near") String near,
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        String[] parts = near.split(",");
        if (parts.length != 3) {
            return ResponseEntity.badRequest().build();
        }
        double latitude = Double.parseDouble(parts[0]);
        double longitude = Double.parseDouble(parts[1]);
        double radius = Double.parseDouble(parts[2]);

        LocalDateTime from = date.atStartOfDay();
        LocalDateTime to = date.atTime(LocalTime.MAX);
        List<EventResponse> events = eventService.searchEvents(latitude, longitude, radius, from, to);
        return ResponseEntity.ok(events);
    }

    @GetMapping("/{id}")
    public ResponseEntity<EventResponse> getEvent(@PathVariable Long id) {
        return ResponseEntity.ok(eventService.getEvent(id));
    }

    @PostMapping("/{id}/join")
    public ResponseEntity<Void> joinEvent(@PathVariable Long id,
                                          @RequestParam(defaultValue = "GOING") EventParticipantStatus status) {
        eventService.joinEvent(id, status);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    @DeleteMapping("/{id}/leave")
    public ResponseEntity<Void> leaveEvent(@PathVariable Long id) {
        eventService.leaveEvent(id);
        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteEvent(@PathVariable Long id) {
        eventService.deleteEvent(id);
        return ResponseEntity.noContent().build();
    }
}
