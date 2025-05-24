package com.pawconnect.backend.match.controller;

import com.pawconnect.backend.common.util.SecurityUtils;
import com.pawconnect.backend.match.dto.CandidateUserResponse;
import com.pawconnect.backend.match.service.MatchService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/matches")
public class MatchController {

    private final MatchService matchService;

    @Autowired
    public MatchController(MatchService matchService) {
        this.matchService = matchService;
    }

//    @GetMapping("/candidates")
//    public List<CandidateUserResponse> getSwipeCandidates(@RequestParam Optional<Double> lat,
//                                                          @RequestParam Optional<Double> lon,
//                                                          @RequestParam Optional<Double> radiusKm) {
//        return matchService.getCandidatesForUser(lat, lon, radiusKm);
//    }
}
