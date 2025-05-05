package com.pawconnect.backend.auth.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
public class UserInfoResponse {
    @Setter
    private Long id;
    @Setter
    private String username;
    @Setter
    private String email;
    private List<String> roles;

    public UserInfoResponse(Long id, String username, String email, List<String> roles) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.roles = roles;
    }

}