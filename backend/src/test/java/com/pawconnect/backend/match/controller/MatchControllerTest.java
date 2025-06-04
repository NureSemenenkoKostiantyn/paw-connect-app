package com.pawconnect.backend.match.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pawconnect.backend.common.enums.SwipeDecision;
import com.pawconnect.backend.match.dto.CandidateUserResponse;
import com.pawconnect.backend.match.dto.SwipeCreateRequest;
import com.pawconnect.backend.match.service.MatchService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
class MatchControllerTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;
    @Autowired private MatchService matchService; // injected mock

    private CandidateUserResponse candidate;
    private SwipeCreateRequest swipeRequest;

    @BeforeEach
    void setUp() {
        candidate = CandidateUserResponse.builder().id(5L).username("u").build();
        swipeRequest = new SwipeCreateRequest(2L, SwipeDecision.LIKE);
    }

    @Test
    void candidates_returnsList() throws Exception {
        when(matchService.getCandidates(20,25)).thenReturn(List.of(candidate));

        mockMvc.perform(get("/api/matches/candidates"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].id").value(5));
    }

    @Test
    void swipe_returnsCreated() throws Exception {
        mockMvc.perform(post("/api/matches/swipes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(swipeRequest)))
                .andExpect(status().isCreated());

        verify(matchService).swipe(any(SwipeCreateRequest.class));
    }

    @Configuration
    @Import(MatchController.class)
    static class TestConfig {
        @Bean
        MatchService matchService() {
            return Mockito.mock(MatchService.class);
        }
    }
}
