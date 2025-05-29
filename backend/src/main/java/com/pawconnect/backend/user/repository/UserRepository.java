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

//    @Query(value = """
//    SELECT
//        u.id AS id,
//        u.username AS username,
//        u.bio AS bio,
//        u.profile_photo_url AS profilePhotoUrl,
//        u.gender AS gender,
//        ST_DistanceSphere(u.location, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)) / 1000 AS distanceKm
//    FROM users u
//    WHERE u.id != :currentUserId
//      AND NOT EXISTS (
//          SELECT 1 FROM swipes s
//          WHERE s.liker_id = :currentUserId AND s.target_id = u.id
//      )
//      AND ST_DWithin(u.location, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326), :radiusMeters)
//    ORDER BY distanceKm ASC
//    LIMIT :limit
//    """, nativeQuery = true)
//    List<CandidateUserProjection> findCandidatesByLocation(
//            @Param("currentUserId") Long currentUserId,
//            @Param("lat") double lat,
//            @Param("lon") double lon,
//            @Param("radiusMeters") double radiusMeters,
//            @Param("limit") int limit
//    );
}
