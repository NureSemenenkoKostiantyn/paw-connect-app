package com.pawconnect.backend.user.repository;


import java.util.Optional;

import com.pawconnect.backend.user.model.ERole;
import com.pawconnect.backend.user.model.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface RoleRepository extends JpaRepository<Role, Long> {
    Optional<Role> findByName(ERole name);
}
