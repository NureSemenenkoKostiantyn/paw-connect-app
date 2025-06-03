package com.pawconnect.backend.match.repository;

import com.pawconnect.backend.match.model.Match;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface MatchRepository extends JpaRepository<Match, Long> {
    /** Checks bidirectional uniqueness so (A,B) & (B,A) aren’t duplicated. */
    @Query("SELECT CASE WHEN COUNT(m) > 0 THEN TRUE ELSE FALSE END FROM Match m " +
            "WHERE (m.user1.id = :u1 AND m.user2.id = :u2) OR (m.user1.id = :u2 AND m.user2.id = :u1)")
    boolean matchExists(@Param("u1") Long user1Id, @Param("u2") Long user2Id);
}
