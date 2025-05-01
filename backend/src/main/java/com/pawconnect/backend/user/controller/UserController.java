package com.pawconnect.backend.user.controller;

import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.UserRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserRepository userRepo;

    public UserController(UserRepository userRepo) {
        this.userRepo = userRepo;
    }

    @PostMapping
    public User createUser(@RequestBody User user) {
        return userRepo.save(user);
    }

    @GetMapping
    public List<User> getAll() {
        return userRepo.findAll();
    }
}
