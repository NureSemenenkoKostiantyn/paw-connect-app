package com.pawconnect.backend.common.exception;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.Instant;

public class ErrorResponseWriter {
    private static final ObjectMapper MAPPER = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

    public static void write(HttpServletResponse response,
                             int status,
                             String error,
                             String message,
                             String path) throws IOException {
        ApiError body = new ApiError(
                Instant.now(),
                status,
                error,
                message,
                path
        );
        response.setStatus(status);
        response.setContentType("application/json");
        MAPPER.writeValue(response.getOutputStream(), body);
    }
}