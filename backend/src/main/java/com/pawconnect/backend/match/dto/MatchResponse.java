package com.pawconnect.backend.match.dto;

import com.pawconnect.backend.user.dto.PublicUserResponse;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MatchResponse {
    private Long id;
    private PublicUserResponse user1;
    private PublicUserResponse user2;
    private String createdAt;
}
