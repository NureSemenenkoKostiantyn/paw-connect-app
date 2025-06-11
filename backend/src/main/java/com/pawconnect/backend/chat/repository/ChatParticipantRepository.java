package com.pawconnect.backend.chat.repository;

import com.pawconnect.backend.chat.model.ChatParticipant;
import com.pawconnect.backend.chat.model.ChatParticipantId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatParticipantRepository extends JpaRepository<ChatParticipant, ChatParticipantId> {
    boolean existsByChatIdAndUserId(Long chatId, Long userId);
    void deleteByChatIdAndUserId(Long chatId, Long userId);
    java.util.Optional<ChatParticipant> findByChatIdAndUserId(Long chatId, Long userId);
}
