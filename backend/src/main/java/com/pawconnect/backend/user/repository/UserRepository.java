package com.pawconnect.backend.user.repository;

import com.pawconnect.backend.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.lang.NonNull;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);

    boolean existsByEmail(String email);
    boolean existsById(@NonNull Long id);
    Boolean existsByUsername(String username);
}
