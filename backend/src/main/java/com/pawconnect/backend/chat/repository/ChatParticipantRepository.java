package com.pawconnect.backend.chat.repository;

import com.pawconnect.backend.chat.model.ChatParticipant;
import com.pawconnect.backend.chat.model.ChatParticipantId;
import com.pawconnect.backend.chat.model.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
public interface ChatParticipantRepository extends JpaRepository<ChatParticipant, ChatParticipantId> {
    boolean existsByChatIdAndUserId(Long chatId, Long userId);
    void deleteByChatIdAndUserId(Long chatId, Long userId);
    Optional<ChatParticipant> findByChatIdAndUserId(Long chatId, Long userId);

    /**
     * Update the last read message for a participant.
     */
    @Transactional
    default void updateLastReadMessage(Long chatId, Long userId, Message message) {
        findByChatIdAndUserId(chatId, userId).ifPresent(p -> {
            p.setLastReadMessage(message);
            save(p);
        });
    }
}
