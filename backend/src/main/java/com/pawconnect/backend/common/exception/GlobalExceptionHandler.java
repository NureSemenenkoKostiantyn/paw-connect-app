package com.pawconnect.backend.common.exception;

import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(InternalAuthenticationServiceException.class)
    public ResponseEntity<ApiError> handleAuthServiceError(
            InternalAuthenticationServiceException ex,
            HttpServletRequest req) {

        // ERROR-level, full stack-trace
        log.error("Authentication service error on [{} {}]",
                req.getMethod(), req.getRequestURI(), ex);

        ApiError error = new ApiError(
                Instant.now(),
                500,
                "Internal Server Error",
                "An internal error occurred during authentication",
                req.getRequestURI()
        );
        return ResponseEntity
                .status(500)
                .body(error);
    }

    @ExceptionHandler({ BadCredentialsException.class,
            AuthenticationException.class })
    public ResponseEntity<ApiError> handleAuthErrors(
            Exception ex,
            HttpServletRequest req) {

        // Log at WARN: expected client mistake or probing
        log.warn("Authentication failed for [{} {}]: {}",
                req.getMethod(),
                req.getRequestURI(),
                ex.getMessage());

        ApiError error = new ApiError(
                Instant.now(),
                HttpStatus.UNAUTHORIZED.value(),
                "Unauthorized",
                ex.getMessage(),
                req.getRequestURI()
        );
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(error);
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiError> handleAccessDenied(
            AccessDeniedException ex,
            HttpServletRequest req) {

        // WARN again: user was authenticated but not allowed
        log.warn("Access denied for [{} {}]: {}",
                req.getMethod(),
                req.getRequestURI(),
                ex.getMessage());

        ApiError error = new ApiError(
                Instant.now(),
                HttpStatus.FORBIDDEN.value(),
                "Forbidden",
                ex.getMessage(),
                req.getRequestURI()
        );
        return ResponseEntity
                .status(HttpStatus.FORBIDDEN)
                .body(error);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(
            MethodArgumentNotValidException ex,
            HttpServletRequest req) {

        String msg = ex.getBindingResult().getFieldErrors().stream()
                .map(fe -> fe.getField() + ": " + fe.getDefaultMessage())
                .collect(Collectors.joining("; "));

        // INFO: validation failures are common, but you may want DEBUG
        log.info("Validation failed for [{} {}]: {}",
                req.getMethod(),
                req.getRequestURI(),
                msg);

        ApiError error = new ApiError(
                Instant.now(),
                HttpStatus.BAD_REQUEST.value(),
                "Validation Failed",
                msg,
                req.getRequestURI()
        );
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> handleAllOthers(
            Exception ex,
            HttpServletRequest req) {

        // ERROR: something truly unexpected happened
        log.error("Internal server error for [{} {}]",
                req.getMethod(),
                req.getRequestURI(),
                ex);  // logs full stack trace

        ApiError error = new ApiError(
                Instant.now(),
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                "Internal Server Error",
                "An unexpected error occurred",
                req.getRequestURI()
        );
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(error);
    }

    @ExceptionHandler(UnauthorizedAccessException.class)
    public ResponseEntity<ApiError> handleUnauthorizedAccess(
            UnauthorizedAccessException ex,
            HttpServletRequest req) {

        // WARN because it’s an unexpected client attempt to access something they shouldn’t
        log.warn("Unauthorized access attempt [{} {}]: {}",
                req.getMethod(),
                req.getRequestURI(),
                ex.getMessage());

        ApiError error = new ApiError(
                Instant.now(),
                HttpStatus.UNAUTHORIZED.value(),
                "Unauthorized",
                ex.getMessage(),
                req.getRequestURI()
        );
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(error);
    }

    /** 404 for missing resources */
    @ExceptionHandler({ NotFoundException.class, EntityNotFoundException.class })
    public ResponseEntity<ApiError> handleNotFound(
            RuntimeException ex,
            HttpServletRequest req) {

        // INFO because “not found” is often benign (e.g. user looked up a missing record)
        log.info("Resource not found [{} {}]: {}",
                req.getMethod(),
                req.getRequestURI(),
                ex.getMessage());

        ApiError error = new ApiError(
                Instant.now(),
                HttpStatus.NOT_FOUND.value(),
                "Not Found",
                ex.getMessage(),
                req.getRequestURI()
        );
        return ResponseEntity
                .status(HttpStatus.NOT_FOUND)
                .body(error);
    }
}
