package com.pawconnect.backend.chat.repository;

import com.pawconnect.backend.chat.model.Chat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatRepository extends JpaRepository<Chat, Long> {
    boolean existsByIdAndParticipantsUserId(Long id, Long userId);
}
