package com.pawconnect.backend.match.dto;

import com.pawconnect.backend.common.enums.SwipeDecision;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SwipeResponse {
    private Long id;
    private Long targetUserId;
    private SwipeDecision decision;
    private boolean matched;
    private String createdAt;
}
