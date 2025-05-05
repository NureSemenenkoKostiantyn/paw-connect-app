package com.pawconnect.backend.user.controller;

import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.service.UserService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

}
