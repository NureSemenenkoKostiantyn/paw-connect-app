package com.pawconnect.backend.dog.service;

import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.exception.UnauthorizedAccessException;
import com.pawconnect.backend.common.util.SecurityUtils;
import com.pawconnect.backend.dog.dto.*;
import com.pawconnect.backend.dog.model.*;
import com.pawconnect.backend.dog.repository.DogRepository;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.service.UserService;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.*;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DogServiceTest {

    @Mock private DogRepository dogRepository;
    @Mock private DogMapper dogMapper;
    @Mock private UserService userService;

    @InjectMocks private DogService dogService;

    private User owner;
    private Dog dog;
    private DogCreateRequest createRequest;
    private DogUpdateRequest updateRequest;
    private DogResponse response;

    @BeforeEach
    void setUp() {
        owner = User.builder().id(1L).build();
        dog = Dog.builder()
                .id(100L)
                .name("Buddy")
                .breed("Labrador")
                .birthdate(LocalDate.of(2020, 1, 1))
                .size("Medium")
                .gender(DogGender.MALE)
                .personality(Personality.PLAYFUL)
                .activityLevel(ActivityLevel.HIGH)
                .owner(owner)
                .build();

        createRequest = new DogCreateRequest();
        createRequest.setName("Buddy");
        createRequest.setBreed("Labrador");
        createRequest.setBirthdate(LocalDate.of(2020, 1, 1));
        createRequest.setSize("Medium");
        createRequest.setGender(DogGender.MALE);
        createRequest.setPersonality(Personality.PLAYFUL);
        createRequest.setActivityLevel(ActivityLevel.HIGH);
        createRequest.setAbout("Happy dog");

        updateRequest = new DogUpdateRequest();
        updateRequest.setName("Buddy Updated");
        updateRequest.setBreed("Golden Retriever");
        updateRequest.setBirthdate(LocalDate.of(2020, 1, 1));
        updateRequest.setSize("Large");
        updateRequest.setGender(DogGender.MALE);
        updateRequest.setPersonality(Personality.FRIENDLY);
        updateRequest.setActivityLevel(ActivityLevel.MEDIUM);
        updateRequest.setAbout("Updated description");

        response = new DogResponse();
        response.setId(100L);
        response.setName("Buddy");
    }

    @Test
    void createDog_shouldSaveDogAndReturnResponse() {
        when(userService.getCurrentUserEntity()).thenReturn(owner);
        when(dogMapper.toEntity(createRequest)).thenReturn(dog);
        when(dogRepository.save(dog)).thenReturn(dog);
        when(dogMapper.toDto(dog)).thenReturn(response);

        DogResponse result = dogService.createDog(createRequest);

        assertEquals(response, result);
        verify(dogRepository).save(dog);
    }

    @Test
    void getDogById_shouldReturnResponseIfExists() {
        when(dogRepository.findById(100L)).thenReturn(Optional.of(dog));
        when(dogMapper.toDto(dog)).thenReturn(response);

        DogResponse result = dogService.getDogById(100L);

        assertEquals(response, result);
    }

    @Test
    void getDogById_shouldThrowNotFoundIfNotExists() {
        when(dogRepository.findById(999L)).thenReturn(Optional.empty());

        assertThrows(NotFoundException.class, () -> dogService.getDogById(999L));
    }

    @Test
    void updateDog_shouldUpdateAndReturnResponseIfOwner() {
        when(dogRepository.findById(100L)).thenReturn(Optional.of(dog));
        try (MockedStatic<SecurityUtils> securityUtils = Mockito.mockStatic(SecurityUtils.class)) {
            securityUtils.when(SecurityUtils::getCurrentUserId).thenReturn(1L);

            doNothing().when(dogMapper).updateDogFromDto(updateRequest, dog);
            when(dogRepository.save(dog)).thenReturn(dog);
            when(dogMapper.toDto(dog)).thenReturn(response);

            DogResponse result = dogService.updateDog(100L, updateRequest);

            assertEquals(response, result);
        }
    }

    @Test
    void updateDog_shouldThrowUnauthorizedIfNotOwner() {
        dog.getOwner().setId(2L); // different user
        when(dogRepository.findById(100L)).thenReturn(Optional.of(dog));

        try (MockedStatic<SecurityUtils> securityUtils = Mockito.mockStatic(SecurityUtils.class)) {
            securityUtils.when(SecurityUtils::getCurrentUserId).thenReturn(1L);

            assertThrows(UnauthorizedAccessException.class, () -> dogService.updateDog(100L, updateRequest));
        }
    }

    @Test
    void deleteDog_shouldDeleteIfOwner() {
        when(dogRepository.findById(100L)).thenReturn(Optional.of(dog));

        try (MockedStatic<SecurityUtils> securityUtils = Mockito.mockStatic(SecurityUtils.class)) {
            securityUtils.when(SecurityUtils::getCurrentUserId).thenReturn(1L);

            dogService.deleteDog(100L);

            verify(dogRepository).delete(dog);
        }
    }

    @Test
    void deleteDog_shouldThrowUnauthorizedIfNotOwner() {
        dog.getOwner().setId(2L);
        when(dogRepository.findById(100L)).thenReturn(Optional.of(dog));

        try (MockedStatic<SecurityUtils> securityUtils = Mockito.mockStatic(SecurityUtils.class)) {
            securityUtils.when(SecurityUtils::getCurrentUserId).thenReturn(1L);

            assertThrows(UnauthorizedAccessException.class, () -> dogService.deleteDog(100L));
        }
    }
}