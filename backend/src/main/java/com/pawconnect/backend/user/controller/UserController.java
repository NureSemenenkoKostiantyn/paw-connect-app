package com.pawconnect.backend.user.controller;

import com.pawconnect.backend.user.dto.CurrentUserResponse;
import com.pawconnect.backend.user.dto.PublicUserResponse;
import com.pawconnect.backend.user.dto.UserUpdateProfileRequest;
import com.pawconnect.backend.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;


@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/current")
    public ResponseEntity<CurrentUserResponse> getCurrentUser() {
        return ResponseEntity.ok(userService.getCurrentUser());
    }

    @GetMapping("/{id}")
    public ResponseEntity<PublicUserResponse> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getPublicUserById(id));
    }

    @PutMapping("/current")
    public ResponseEntity<CurrentUserResponse> updateCurrentUser(@Valid @RequestBody UserUpdateProfileRequest currentUser) {
        return ResponseEntity.ok(userService.updateCurrentUserProfile(currentUser));
    }

    @DeleteMapping("/current")
    public ResponseEntity<Void> deleteCurrentUser() {
        userService.deleteCurrentUser();
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/current/profile-photo")
    public ResponseEntity<CurrentUserResponse> uploadProfilePhoto(@RequestPart("file") MultipartFile file) throws IOException {
        return ResponseEntity.ok(userService.uploadProfilePhoto(file));
    }

    @DeleteMapping("/current/profile-photo")
    public ResponseEntity<Void> deleteProfilePhoto() {
        userService.deleteProfilePhoto();
        return ResponseEntity.noContent().build();
    }

}
