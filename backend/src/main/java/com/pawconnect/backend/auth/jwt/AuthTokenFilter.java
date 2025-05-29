package com.pawconnect.backend.auth.jwt;

import com.pawconnect.backend.auth.service.UserDetailsServiceImpl;
import com.pawconnect.backend.common.util.JwtUtils;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.security.SignatureException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

public class AuthTokenFilter extends OncePerRequestFilter {
    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private UserDetailsServiceImpl userDetailsService;

    private static final Logger logger = LoggerFactory.getLogger(AuthTokenFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest req,
                                    HttpServletResponse res,
                                    FilterChain chain)
            throws ServletException, IOException {
        try {
            String jwt = parseJwt(req);
            if (jwt != null) {
                // Validate format & signature
                jwtUtils.validateJwtToken(jwt);

                // Extract username (may still be valid even if not in DB)
                String username = jwtUtils.getUserNameFromJwtToken(jwt);

                // This can throw UsernameNotFoundException
                UserDetails details = userDetailsService.loadUserByUsername(username);

                // Build auth and set context
                UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                        details, null, details.getAuthorities());
                auth.setDetails(new WebAuthenticationDetailsSource().buildDetails(req));
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
        } catch (ExpiredJwtException err) {
            logger.warn("JWT expired for request to {}: {}", req.getRequestURI(), err.getMessage());
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Token expired");
            return;
        } catch (MalformedJwtException | SignatureException | IllegalArgumentException err) {
            logger.warn("Invalid JWT for request to {}: {}", req.getRequestURI(), err.getMessage());
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid token");
            return;
        } catch (UsernameNotFoundException err) {
            // User not in database → treat as unauthorized token
            logger.info("User '{}' not found (JWT was valid): {}", err.getMessage(), req.getRequestURI());
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not found");
            return;
        } catch (Exception err) {
            // Unexpected errors bubble up as 500 so you’ll see a single stack‐trace
            logger.error("Unexpected error in AuthTokenFilter", err);
            throw err;
        }

        chain.doFilter(req, res);
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getServletPath();
        // skip auth on your public endpoints:
        return path.startsWith("/api/auth")
                || path.startsWith("/swagger-ui")
                || path.startsWith("/v3");
    }


    private String parseJwt(HttpServletRequest request) {
        return jwtUtils.getJwtFromCookies(request);
    }
}
