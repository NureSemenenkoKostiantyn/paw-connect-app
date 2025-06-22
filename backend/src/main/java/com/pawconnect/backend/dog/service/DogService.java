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
import com.pawconnect.backend.common.BlobStorageService;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;

@Service
public class DogService {

    private final DogRepository dogRepository;
    private final DogMapper dogMapper;
    private final UserService userService;
    private final BlobStorageService blobStorageService;

    @Autowired
    public DogService(DogRepository dogRepository, DogMapper dogMapper, UserService userService,
                      BlobStorageService blobStorageService) {
        this.dogRepository = dogRepository;
        this.dogMapper = dogMapper;
        this.userService = userService;
        this.blobStorageService = blobStorageService;
    }

    public DogResponse createDog(DogCreateRequest request) {
        User currentUser = userService.getCurrentUserEntity();

        Dog dog = dogMapper.toEntity(request);
        dog.setOwner(currentUser);

        DogResponse dto = dogMapper.toDto(dogRepository.save(dog));
        enrichWithSas(dto);
        return dto;
    }

    public DogResponse getDogById(Long id) {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));
        DogResponse dto = dogMapper.toDto(dog);
        enrichWithSas(dto);
        return dto;
    }

    public DogResponse updateDog(Long id, DogUpdateRequest request) {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));

        if (!dog.getOwner().getId().equals(SecurityUtils.getCurrentUserId())) {
            throw new UnauthorizedAccessException("You are not the owner of this dog");
        }

        dogMapper.updateDogFromDto(request, dog);
        DogResponse dto = dogMapper.toDto(dogRepository.save(dog));
        enrichWithSas(dto);
        return dto;
    }

    public void deleteDog(Long id) {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));

        if (!dog.getOwner().getId().equals(SecurityUtils.getCurrentUserId())) {
            throw new UnauthorizedAccessException("You are not the owner of this dog");
        }

        if (dog.getPhotoUrls() != null) {
            dog.getPhotoUrls().forEach(blobStorageService::delete);
        }
        dogRepository.delete(dog);
    }

    public DogResponse addPhoto(Long id, MultipartFile file) throws IOException {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));

        if (!dog.getOwner().getId().equals(SecurityUtils.getCurrentUserId())) {
            throw new UnauthorizedAccessException("You are not the owner of this dog");
        }

        String blobName = blobStorageService.upload(file, "dogs");
        if (dog.getPhotoUrls() == null) {
            dog.setPhotoUrls(new java.util.ArrayList<>());
        }
        dog.getPhotoUrls().add(blobName);
        DogResponse dto = dogMapper.toDto(dogRepository.save(dog));
        enrichWithSas(dto);
        return dto;
    }

    public void deletePhoto(Long id, String blobName) {
        Dog dog = dogRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Dog not found"));

        if (!dog.getOwner().getId().equals(SecurityUtils.getCurrentUserId())) {
            throw new UnauthorizedAccessException("You are not the owner of this dog");
        }

        if (dog.getPhotoUrls() != null && dog.getPhotoUrls().remove(blobName)) {
            blobStorageService.delete(blobName);
            dogRepository.save(dog);
        }
    }

    private void enrichWithSas(DogResponse dto) {
        if (dto.getPhotoUrls() != null) {
            dto.setPhotoUrls(dto.getPhotoUrls().stream()
                    .map(blobStorageService::generateReadSasUrl)
                    .toList());
        }
    }
}

