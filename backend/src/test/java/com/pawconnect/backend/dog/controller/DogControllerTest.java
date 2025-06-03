package com.pawconnect.backend.dog.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pawconnect.backend.dog.dto.*;
import com.pawconnect.backend.dog.model.*;
import com.pawconnect.backend.dog.service.DogService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
class DogControllerTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;

    @Autowired private DogService dogService; // injected via test config

    private DogCreateRequest createRequest;
    private DogUpdateRequest updateRequest;
    private DogResponse response;

    @BeforeEach
    void setup() {
        createRequest = new DogCreateRequest();
        createRequest.setName("Rex");
        createRequest.setBreed("Beagle");
        createRequest.setBirthdate(LocalDate.of(2021, 5, 10));
        createRequest.setSize(DogSize.SMALL);
        createRequest.setGender(DogGender.MALE);
        createRequest.setPersonality(Personality.FRIENDLY);
        createRequest.setActivityLevel(ActivityLevel.MEDIUM);
        createRequest.setAbout("Nice dog");

        updateRequest = new DogUpdateRequest();
        updateRequest.setName("Max");
        updateRequest.setBreed("Terrier");
        updateRequest.setBirthdate(LocalDate.of(2020, 3, 15));
        updateRequest.setSize(DogSize.MEDIUM);
        updateRequest.setGender(DogGender.MALE);
        updateRequest.setPersonality(Personality.PLAYFUL);
        updateRequest.setActivityLevel(ActivityLevel.HIGH);
        updateRequest.setAbout("Very energetic");

        response = new DogResponse();
        response.setId(1L);
        response.setName("Rex");
        response.setBreed("Beagle");
        response.setBirthdate(LocalDate.of(2021, 5, 10));
        response.setSize("Small");
        response.setGender(DogGender.MALE);
        response.setPersonality(Personality.FRIENDLY);
        response.setActivityLevel(ActivityLevel.MEDIUM);
        response.setAbout("Nice dog");
        response.setPhotoUrls(List.of());
        response.setOwnerId(100L);
    }

    @Test
    void createDog_shouldReturnDogResponse() throws Exception {
        when(dogService.createDog(any())).thenReturn(response);

        mockMvc.perform(post("/api/dogs")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Rex"));
    }

    @Test
    void getDogById_shouldReturnDogResponse() throws Exception {
        when(dogService.getDogById(1L)).thenReturn(response);

        mockMvc.perform(get("/api/dogs/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1));
    }

    @Test
    void updateDog_shouldReturnUpdatedDog() throws Exception {
        response.setName("Max");
        when(dogService.updateDog(Mockito.eq(1L), any())).thenReturn(response);

        mockMvc.perform(put("/api/dogs/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Max"));
    }

    @Test
    void deleteDog_shouldReturnNoContent() throws Exception {
        mockMvc.perform(delete("/api/dogs/1"))
                .andExpect(status().isNoContent());
    }

    @Configuration
    @Import(DogController.class)
    static class TestConfig {
        @Bean
        public DogService dogService() {
            return Mockito.mock(DogService.class);
        }
    }
}