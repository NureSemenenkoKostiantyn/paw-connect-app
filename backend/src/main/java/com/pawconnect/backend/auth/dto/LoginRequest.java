package com.pawconnect.backend.auth.dto;

import lombok.*;

@Setter
@Getter
public class LoginRequest {
    private String username;
    private String password;

}
