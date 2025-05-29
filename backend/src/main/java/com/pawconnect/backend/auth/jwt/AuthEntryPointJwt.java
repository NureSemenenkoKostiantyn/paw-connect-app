package com.pawconnect.backend.auth.jwt;

import java.io.IOException;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pawconnect.backend.common.exception.ErrorResponseWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

@Component
public class AuthEntryPointJwt implements AuthenticationEntryPoint {

    private static final Logger logger = LoggerFactory.getLogger(AuthEntryPointJwt.class);

    @Override
    public void commence(HttpServletRequest req,
                         HttpServletResponse res,
                         AuthenticationException authEx)
            throws IOException {
        if ("OPTIONS".equalsIgnoreCase(req.getMethod())) {
            res.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        logger.warn("Unauthorized request [{} {}]: {}",
                req.getMethod(),
                req.getRequestURI(),
                authEx.getMessage());

        ErrorResponseWriter.write(
                res,
                HttpServletResponse.SC_UNAUTHORIZED,
                "Unauthorized",
                authEx.getMessage(),
                req.getRequestURI()
        );
    }
}
