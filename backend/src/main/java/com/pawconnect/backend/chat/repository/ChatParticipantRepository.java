package com.pawconnect.backend.chat.repository;

import com.pawconnect.backend.chat.model.ChatParticipant;
import com.pawconnect.backend.chat.model.ChatParticipantId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ChatParticipantRepository extends JpaRepository<ChatParticipant, ChatParticipantId> {
    boolean existsByChatIdAndUserId(Long chatId, Long userId);
    void deleteByChatIdAndUserId(Long chatId, Long userId);
    Optional<ChatParticipant> findByChatIdAndUserId(Long chatId, Long userId);
}
