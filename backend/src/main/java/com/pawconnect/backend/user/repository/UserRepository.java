package com.pawconnect.backend.user.repository;

import com.pawconnect.backend.user.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);

    boolean existsByEmail(String email);
    boolean existsById(@NonNull Long id);
    Boolean existsByUsername(String username);

    @Query("""
    SELECT u FROM User u
    WHERE u.id != :currentUserId
      AND u.id NOT IN (
         SELECT s.target.id FROM Swipe s WHERE s.liker.id = :currentUserId
      )
      AND (:lat IS NULL OR ST_DistanceSphere(POINT(u.longitude, u.latitude), POINT(:lon, :lat)) <= :radiusMeters)
    """)
    List<User> findCandidates(@Param("currentUserId") Long currentUserId,
                              @Param("lat") Double lat,
                              @Param("lon") Double lon,
                              @Param("radiusMeters") Double radiusMeters);
}
