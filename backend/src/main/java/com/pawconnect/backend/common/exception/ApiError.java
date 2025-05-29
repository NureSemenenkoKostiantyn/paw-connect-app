package com.pawconnect.backend.common.exception;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.Instant;

public record ApiError(
        Instant timestamp,
        int status,
        String error,
        String message,
        String path
) {}