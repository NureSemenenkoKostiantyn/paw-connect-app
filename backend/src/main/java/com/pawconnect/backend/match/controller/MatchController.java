package com.pawconnect.backend.match.controller;

import com.pawconnect.backend.match.dto.CandidateUserResponse;
import com.pawconnect.backend.match.dto.SwipeCreateRequest;
import com.pawconnect.backend.match.service.MatchService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/matches")
@RequiredArgsConstructor
@Validated
public class MatchController {

    private final MatchService matchService;

    @GetMapping("/candidates")
    public List<CandidateUserResponse> candidates(
            @RequestParam(defaultValue = "20") @Min(1) @Max(100) int limit,
            @RequestParam(defaultValue = "25") @Min(1)           double radiusKm) {
        return matchService.getCandidates(limit, radiusKm);
    }

    @PostMapping("/swipes")
    @ResponseStatus(HttpStatus.CREATED)
    public void swipe(@RequestBody @Valid SwipeCreateRequest request) {
        matchService.swipe(request);
    }
}
