package com.pawconnect.backend.user.controller;

import com.pawconnect.backend.user.dto.PreferenceResponse;
import com.pawconnect.backend.user.dto.PreferenceUpdateRequest;
import com.pawconnect.backend.user.service.PreferenceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/preferences")
@RequiredArgsConstructor
public class PreferenceController {

    private final PreferenceService preferenceService;

    @GetMapping("/current")
    public ResponseEntity<PreferenceResponse> getCurrentPreferences() {
        return ResponseEntity.ok(preferenceService.getCurrentPreference());
    }

    @PutMapping("/current")
    public ResponseEntity<PreferenceResponse> updateCurrentPreferences(
            @Valid @RequestBody PreferenceUpdateRequest request) {
        return ResponseEntity.ok(preferenceService.updateCurrentPreference(request));
    }
}
