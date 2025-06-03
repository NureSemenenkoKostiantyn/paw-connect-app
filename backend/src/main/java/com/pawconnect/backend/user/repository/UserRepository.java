package com.pawconnect.backend.user.repository;

import com.pawconnect.backend.match.dto.RankedCandidateRow;
import com.pawconnect.backend.user.model.User;
import org.locationtech.jts.geom.Point;
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

    /**
     * Returns already‑ranked candidates limited to {@code limit}.  The heavy
     * lifting (distance filter, anti‑join, weight calculation, ORDER BY) lives
     * entirely inside the SQL.
     */
    @Query(value = """

            WITH my_pref AS (SELECT * FROM preferences WHERE user_id = :currentUserId)
        SELECT   u.id AS user_id,
                 ST_Distance(u.location, :loc) / 1000.0 AS distance_km,
                 s.score
        FROM     users u
        JOIN LATERAL (
            SELECT MAX(
                 (CASE WHEN p.preferred_personality IS NOT NULL
                           AND p.preferred_personality = d.personality THEN 5 ELSE 0 END)
               + (CASE WHEN p.preferred_activity_level IS NOT NULL
                           AND p.preferred_activity_level = d.activity_level THEN 5 ELSE 0 END)
               + (CASE WHEN p.preferred_size IS NOT NULL
                           AND p.preferred_size = d.size THEN 4 ELSE 0 END)
               + (CASE WHEN p.preferred_gender IS NOT NULL
                           AND p.preferred_gender = d.gender THEN 4 ELSE 0 END)
            ) AS score
            FROM dogs d
            JOIN my_pref p ON TRUE
            WHERE d.owner_id = u.id
        ) s ON TRUE
        WHERE    u.id <> :currentUserId
          AND    NOT EXISTS (
                    SELECT 1 FROM swipes s
                    WHERE  s.liker_id  = :currentUserId
                      AND  s.target_id = u.id)
          AND    ST_DWithin(u.location, :loc, :radiusM)
        ORDER BY score DESC, distance_km ASC
        LIMIT    :limit
        """, nativeQuery = true)
    List<RankedCandidateRow> findRankedCandidates(@Param("currentUserId") Long currentUserId,
                                                  @Param("loc") Point currentLocation,
                                                  @Param("radiusM") double radiusMetres,
                                                  @Param("limit") int limit);
}
