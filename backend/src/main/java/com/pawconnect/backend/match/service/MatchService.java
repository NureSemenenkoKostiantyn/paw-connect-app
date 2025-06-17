package com.pawconnect.backend.match.service;


import com.pawconnect.backend.common.enums.SwipeDecision;
import com.pawconnect.backend.match.dto.CandidateUserResponse;
import com.pawconnect.backend.match.dto.RankedCandidateRow;
import com.pawconnect.backend.match.dto.SwipeCreateRequest;
import com.pawconnect.backend.chat.service.ChatService;
import com.pawconnect.backend.match.model.Match;
import com.pawconnect.backend.match.model.Swipe;
import com.pawconnect.backend.match.repository.MatchRepository;
import com.pawconnect.backend.match.repository.SwipeRepository;
import com.pawconnect.backend.user.dto.PublicUserResponse;
import com.pawconnect.backend.user.dto.UserMapper;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.UserRepository;
import com.pawconnect.backend.user.service.UserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Point;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final MatchRepository matchRepository;
    private final SwipeRepository swipeRepository;
    private final UserRepository userRepository;
    private final UserService userService;
    private final UserMapper userMapper;
    private final ChatService chatService;

    public List<CandidateUserResponse> getCandidates(int limit, double radiusKm) {
        User currentUser = userService.getCurrentUserEntity();
        Point loc = currentUser.getLocation();

        double radiusM = radiusKm > 100 ? 50_000 * 1000.0 : radiusKm * 1000.0;

        List<RankedCandidateRow> rows = userRepository.findRankedCandidates(
                currentUser.getId(), loc, radiusM, limit);

        // Load the User entities in batch so we can reuse the existing UserMapper
        List<Long> ids = rows.stream().map(RankedCandidateRow::getUser_id).toList();
        Map<Long, User> userMap = (userRepository.findAllById(ids))
                .stream().collect(Collectors.toMap(User::getId, Function.identity()));

        return rows.stream()
                .map(r -> toDto(r, userMap.get(r.getUser_id())))
                .collect(Collectors.toList());
    }

    private CandidateUserResponse toDto(RankedCandidateRow row, User userEntity) {
        PublicUserResponse base = userMapper.toPublicUserResponse(userEntity);
        return CandidateUserResponse.builder()
                .id(base.getId())
                .username(base.getUsername())
                .bio(base.getBio())
                .gender(base.getGender())
                .profilePhotoUrl(base.getProfilePhotoUrl())
                .dogs(base.getDogs())
                .languages(base.getLanguages())
                .distanceKm(row.getDistance_km())
                .score(row.getScore())
                .build();
    }

    @Transactional
    public void swipe(SwipeCreateRequest req) {
        User currentUser = userService.getCurrentUserEntity();
        if (swipeRepository.existsByLikerIdAndTargetId(currentUser.getId(), req.targetUserId())) {
            throw new IllegalStateException("You have already swiped on this user");
        }
        User target = userRepository.findById(req.targetUserId())
                .orElseThrow(() -> new IllegalArgumentException("Target user not found"));

        Swipe swipe = Swipe.builder()
                .liker(currentUser)
                .target(target)
                .decision(req.decision())
                .createdAt(LocalDateTime.now())
                .build();
        swipeRepository.save(swipe);

        if (req.decision() == SwipeDecision.LIKE) {
            swipeRepository.findByLikerIdAndTargetIdAndDecision(target.getId(), currentUser.getId(), com.pawconnect.backend.common.enums.SwipeDecision.LIKE)
                    .ifPresent(r -> createMatchIfAbsent(currentUser, target));
        }
    }

    private void createMatchIfAbsent(User u1, User u2) {
        if (!matchRepository.matchExists(u1.getId(), u2.getId())) {
            matchRepository.save(Match.builder()
                    .user1(u1)
                    .user2(u2)
                    .createdAt(LocalDateTime.now())
                    .build());
            chatService.createPrivateChat(u1, u2);
        }
    }


}
