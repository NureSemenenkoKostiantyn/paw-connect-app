package com.pawconnect.backend.match.service;


import com.pawconnect.backend.match.dto.CandidateUserResponse;
import com.pawconnect.backend.match.repository.MatchRepository;
import com.pawconnect.backend.user.dto.UserMapper;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.UserRepository;
import com.pawconnect.backend.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MatchService {

    private final MatchRepository matchRepository;
    private final UserRepository userRepository;
    private final UserService userService;
    private final UserMapper userMapper;


    @Autowired
    public MatchService(
            MatchRepository matchRepository,
            UserService userService,
            UserRepository userRepository,
            UserMapper userMapper
    ) {
        this.matchRepository = matchRepository;
        this.userRepository = userRepository;
        this.userService = userService;
        this.userMapper = userMapper;
    }

//    public List<CandidateUserResponse> getCandidates(
//            Optional<Double> lat,
//            Optional<Double> lon,
//            Optional<Double> radiusKm
//    ) {
//        User currentUser = userService.getCurrentUserEntity();
//        List<User> candidates = userRepository.findCandidates(
//                currentUser.getId(),
//                lat.orElse(null),
//                lon.orElse(null),
//                radiusKm.map(km -> km * 1000).orElse(5000.0) // default 5km
//        );
//
//        return candidates.stream()
//                .map(candidate -> {
//                    double distance = calculateDistance(currentUser, candidate);
//                    return userMapper.toCandidateUserResponse(candidate, distance);
//                })
//                .toList();
//    }
}
