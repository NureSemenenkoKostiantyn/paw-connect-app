package com.pawconnect.backend.user.service;

import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.util.SecurityUtils;
import com.pawconnect.backend.user.dto.CurrentUserResponse;
import com.pawconnect.backend.user.dto.PublicUserResponse;
import com.pawconnect.backend.user.dto.UserMapper;
import com.pawconnect.backend.user.dto.UserUpdateProfileRequest;
import com.pawconnect.backend.common.BlobStorageService;
import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.user.model.Language;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.LanguageRepository;
import com.pawconnect.backend.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashSet;
import java.util.List;
import java.io.IOException;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final LanguageRepository languageRepository;
    private final BlobStorageService blobStorageService;

    @Autowired
    public UserService(UserRepository userRepository, UserMapper userMapper,
                       LanguageRepository languageRepository,
                       BlobStorageService blobStorageService) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.languageRepository = languageRepository;
        this.blobStorageService = blobStorageService;
    }

    public User getCurrentUserEntity() {
        Long userId = SecurityUtils.getCurrentUserId();
        return userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User is not found"));
    }

    public CurrentUserResponse getCurrentUser() {
        CurrentUserResponse resp = userMapper.toCurrentUserResponse(getCurrentUserEntity());
        enrich(resp.getDogs());
        if (resp.getProfilePhotoUrl() != null) {
            resp.setProfilePhotoUrl(blobStorageService.generateReadSasUrl(resp.getProfilePhotoUrl()));
        }
        return resp;
    }

    public PublicUserResponse getPublicUserById(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));
        PublicUserResponse resp = userMapper.toPublicUserResponse(user);
        enrich(resp.getDogs());
        if (resp.getProfilePhotoUrl() != null) {
            resp.setProfilePhotoUrl(blobStorageService.generateReadSasUrl(resp.getProfilePhotoUrl()));
        }
        return resp;
    }

    public void deleteCurrentUser() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new NotFoundException("User not found");
        }
        User user = userRepository.findById(userId).orElseThrow();
        if (user.getProfilePhotoUrl() != null) {
            blobStorageService.delete(user.getProfilePhotoUrl());
        }
        if (user.getDogs() != null) {
            user.getDogs().forEach(dog -> {
                if (dog.getPhotoUrls() != null) {
                    dog.getPhotoUrls().forEach(blobStorageService::delete);
                }
            });
        }
        userRepository.deleteById(userId);
    }

    public CurrentUserResponse uploadProfilePhoto(MultipartFile file) throws IOException {
        User user = getCurrentUserEntity();
        if (user.getProfilePhotoUrl() != null) {
            blobStorageService.delete(user.getProfilePhotoUrl());
        }
        String blobName = blobStorageService.upload(file, "profiles");
        user.setProfilePhotoUrl(blobName);
        CurrentUserResponse resp = userMapper.toCurrentUserResponse(userRepository.save(user));
        enrich(resp.getDogs());
        resp.setProfilePhotoUrl(blobStorageService.generateReadSasUrl(blobName));
        return resp;
    }

    public void deleteProfilePhoto() {
        User user = getCurrentUserEntity();
        if (user.getProfilePhotoUrl() != null) {
            blobStorageService.delete(user.getProfilePhotoUrl());
            user.setProfilePhotoUrl(null);
            userRepository.save(user);
        }
    }

    public CurrentUserResponse updateCurrentUserProfile(UserUpdateProfileRequest request) {
        User user = getCurrentUserEntity();

        userMapper.updateUserProfileFromDto(request, user);

        if (request.getLanguageIds() != null && !request.getLanguageIds().isEmpty()) {
            List<Language> languages = languageRepository.findAllById(request.getLanguageIds());
            if (languages.size() != request.getLanguageIds().size()) {
                throw new NotFoundException("One or more selected languages not found");
            }
            user.setLanguages(new HashSet<>(languages));
        }

        CurrentUserResponse resp = userMapper.toCurrentUserResponse(userRepository.save(user));
        enrich(resp.getDogs());
        if (resp.getProfilePhotoUrl() != null) {
            resp.setProfilePhotoUrl(blobStorageService.generateReadSasUrl(resp.getProfilePhotoUrl()));
        }
        return resp;
    }

    private void enrich(List<DogResponse> dogs) {
        if (dogs != null) {
            dogs.forEach(d -> {
                if (d.getPhotoUrls() != null) {
                    d.setPhotoUrls(d.getPhotoUrls().stream()
                            .map(blobStorageService::generateReadSasUrl)
                            .toList());
                }
            });
        }
    }
}
