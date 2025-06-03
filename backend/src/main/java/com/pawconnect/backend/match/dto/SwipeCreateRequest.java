package com.pawconnect.backend.match.dto;

import com.pawconnect.backend.common.enums.SwipeDecision;
import jakarta.validation.constraints.NotNull;

public record SwipeCreateRequest(
        @NotNull Long targetUserId,
        @NotNull SwipeDecision decision
) {}
