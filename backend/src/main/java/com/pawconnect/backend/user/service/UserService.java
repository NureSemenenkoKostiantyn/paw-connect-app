package com.pawconnect.backend.user.service;

import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.util.SecurityUtils;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User getCurrentUser() {
        Long userId = SecurityUtils.getCurrentUserId();
        return userRepository.findById(userId)
                .orElseThrow(() -> new NotFoundException("User is not found"));
    }
}
