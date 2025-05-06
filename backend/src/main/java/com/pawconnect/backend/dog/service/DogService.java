package com.pawconnect.backend.dog.service;

import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.exception.UnauthorizedAccessException;
import com.pawconnect.backend.common.util.SecurityUtils;
import com.pawconnect.backend.dog.dto.DogCreateRequest;
import com.pawconnect.backend.dog.dto.DogMapper;
import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.dog.dto.DogUpdateRequest;
import com.pawconnect.backend.dog.model.Dog;
import com.pawconnect.backend.dog.repository.DogRepository;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class DogService {

    private final DogRepository dogRepository;
    private final DogMapper dogMapper;
    private final UserService userService;

    @Autowired
    public DogService(DogRepository dogRepository, DogMapper dogMapper, UserService userService) {
        this.dogRepository = dogRepository;
        this.dogMapper = dogMapper;
        this.userService = userService;
    }

    public DogResponse createDog(DogCreateRequest request) {
        User currentUser = userService.getCurrentUser();

        Dog dog = dogMapper.toEntity(request);
        dog.setOwner(currentUser);

        return dogMapper.toDto(dogRepository.save(dog));
    }

    public DogResponse getDogById(Long id) {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));
        return dogMapper.toDto(dog);
    }

    public DogResponse updateDog(Long id, DogUpdateRequest request) {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));

        if (!dog.getOwner().getId().equals(SecurityUtils.getCurrentUserId())) {
            throw new UnauthorizedAccessException("You are not the owner of this dog");
        }

        dogMapper.updateDogFromDto(request, dog);
        return dogMapper.toDto(dogRepository.save(dog));
    }

    public void deleteDog(Long id) {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));

        if (!dog.getOwner().getId().equals(SecurityUtils.getCurrentUserId())) {
            throw new UnauthorizedAccessException("You are not the owner of this dog");
        }

        dogRepository.delete(dog);
    }
}

