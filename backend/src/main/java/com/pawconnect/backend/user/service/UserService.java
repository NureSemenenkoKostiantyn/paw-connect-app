package com.pawconnect.backend.user.service;

import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.util.SecurityUtils;
import com.pawconnect.backend.user.dto.CurrentUserResponse;
import com.pawconnect.backend.user.dto.PublicUserResponse;
import com.pawconnect.backend.user.dto.UserMapper;
import com.pawconnect.backend.user.dto.UserUpdateProfileRequest;
import com.pawconnect.backend.user.model.Language;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.LanguageRepository;
import com.pawconnect.backend.user.repository.UserRepository;
import com.pawconnect.backend.common.storage.BlobStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final LanguageRepository languageRepository;
    private final BlobStorageService blobStorageService;

    @Autowired
    public UserService(UserRepository userRepository, UserMapper userMapper, LanguageRepository languageRepository, BlobStorageService blobStorageService) {
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
        return userMapper.toCurrentUserResponse(getCurrentUserEntity());
    }

    public PublicUserResponse getPublicUserById(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User not found"));
        return userMapper.toPublicUserResponse(user);
    }

    public void deleteCurrentUser() {
        Long userId = SecurityUtils.getCurrentUserId();
        if (!userRepository.existsById(userId)) {
            throw new NotFoundException("User not found");
        }
        userRepository.findById(userId).ifPresent(u -> {
            blobStorageService.delete(u.getProfilePhotoBlobName());
            if (u.getDogs() != null) {
                u.getDogs().forEach(dog -> {
                    if (dog.getPhotoBlobNames() != null) {
                        dog.getPhotoBlobNames().forEach(blobStorageService::delete);
                    }
                });
            }
        });
        userRepository.deleteById(userId);
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

        return userMapper.toCurrentUserResponse(userRepository.save(user));
    }
}
