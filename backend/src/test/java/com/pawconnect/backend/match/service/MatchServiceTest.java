package com.pawconnect.backend.match.service;

import com.pawconnect.backend.common.enums.SwipeDecision;
import com.pawconnect.backend.match.dto.CandidateUserResponse;
import com.pawconnect.backend.match.dto.SwipeCreateRequest;
import com.pawconnect.backend.match.dto.RankedCandidateRow;
import com.pawconnect.backend.match.model.Match;
import com.pawconnect.backend.match.model.Swipe;
import com.pawconnect.backend.match.repository.MatchRepository;
import com.pawconnect.backend.match.repository.SwipeRepository;
import com.pawconnect.backend.chat.service.ChatService;
import com.pawconnect.backend.user.dto.PublicUserResponse;
import com.pawconnect.backend.user.dto.UserMapper;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.model.UserGender;
import com.pawconnect.backend.user.repository.UserRepository;
import com.pawconnect.backend.user.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MatchServiceTest {

    @Mock
    private MatchRepository matchRepository;
    @Mock
    private SwipeRepository swipeRepository;
    @Mock
    private UserRepository userRepository;
    @Mock
    private UserService userService;
    @Mock
    private UserMapper userMapper;
    @Mock
    private ChatService chatService;

    @InjectMocks
    private MatchService matchService;

    private User currentUser;
    private User targetUser;
    private Point point;

    @BeforeEach
    void setUp() {
        point = new GeometryFactory().createPoint(new Coordinate(1.0,2.0));
        currentUser = User.builder().id(1L).location(point).build();
        targetUser = User.builder().id(2L).build();
    }

    @Test
    void getCandidates_returnsMappedList() {
        RankedCandidateRow row = mock(RankedCandidateRow.class);
        when(row.getUser_id()).thenReturn(2L);
        when(row.getDistance_km()).thenReturn(3.5);
        when(row.getScore()).thenReturn(10);

        when(userService.getCurrentUserEntity()).thenReturn(currentUser);
        when(userRepository.findRankedCandidates(eq(1L), eq(point), eq(25000.0), eq(5)))
                .thenReturn(List.of(row));
        when(userRepository.findAllById(List.of(2L))).thenReturn(List.of(targetUser));

        PublicUserResponse pub = new PublicUserResponse();
        pub.setId(2L);
        pub.setUsername("bob");
        pub.setBio("bio");
        pub.setAge(0);
        pub.setGender(UserGender.MALE);
        pub.setProfilePhotoUrl("pic");
        pub.setLanguages(Set.of("en"));
        pub.setDogs(List.of());
        when(userMapper.toPublicUserResponse(targetUser)).thenReturn(pub);

        List<CandidateUserResponse> result = matchService.getCandidates(5,25);
        assertEquals(1, result.size());
        CandidateUserResponse r = result.get(0);
        assertEquals(2L, r.getId());
        assertEquals("bob", r.getUsername());
        assertEquals(3.5, r.getDistanceKm());
        assertEquals(10, r.getScore());
    }

    @Test
    void swipe_existingSwipeThrows() {
        SwipeCreateRequest req = new SwipeCreateRequest(2L, SwipeDecision.LIKE);
        when(userService.getCurrentUserEntity()).thenReturn(currentUser);
        when(swipeRepository.existsByLikerIdAndTargetId(1L,2L)).thenReturn(true);
        assertThrows(IllegalStateException.class, () -> matchService.swipe(req));
        verify(swipeRepository, never()).save(any());
    }

    @Test
    void swipe_passCreatesSwipeOnly() {
        SwipeCreateRequest req = new SwipeCreateRequest(2L, SwipeDecision.PASS);
        when(userService.getCurrentUserEntity()).thenReturn(currentUser);
        when(swipeRepository.existsByLikerIdAndTargetId(1L,2L)).thenReturn(false);
        when(userRepository.findById(2L)).thenReturn(Optional.of(targetUser));

        matchService.swipe(req);

        verify(swipeRepository).save(any(Swipe.class));
        verify(matchRepository, never()).save(any());
    }

    @Test
    void swipe_likeCreatesMatchWhenReciprocal() {
        SwipeCreateRequest req = new SwipeCreateRequest(2L, SwipeDecision.LIKE);
        when(userService.getCurrentUserEntity()).thenReturn(currentUser);
        when(swipeRepository.existsByLikerIdAndTargetId(1L,2L)).thenReturn(false);
        when(userRepository.findById(2L)).thenReturn(Optional.of(targetUser));
        when(swipeRepository.findByLikerIdAndTargetIdAndDecision(2L,1L, SwipeDecision.LIKE))
                .thenReturn(Optional.of(new Swipe()));
        when(matchRepository.matchExists(1L,2L)).thenReturn(false);

        matchService.swipe(req);

        verify(matchRepository).save(any(Match.class));
        verify(chatService).createPrivateChat(currentUser, targetUser);
    }

    @Test
    void swipe_targetNotFound() {
        SwipeCreateRequest req = new SwipeCreateRequest(2L, SwipeDecision.LIKE);
        when(userService.getCurrentUserEntity()).thenReturn(currentUser);
        when(swipeRepository.existsByLikerIdAndTargetId(1L,2L)).thenReturn(false);
        when(userRepository.findById(2L)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () -> matchService.swipe(req));
    }
}
