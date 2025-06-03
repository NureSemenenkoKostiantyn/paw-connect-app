package com.pawconnect.backend.match.repository;

import com.pawconnect.backend.common.enums.SwipeDecision;
import com.pawconnect.backend.match.model.Swipe;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface SwipeRepository extends JpaRepository<Swipe, Long> {
    boolean existsByLikerIdAndTargetId(Long likerId, Long targetId);
    Optional<Swipe> findByLikerIdAndTargetIdAndDecision(Long likerId, Long targetId, SwipeDecision decision);
}
