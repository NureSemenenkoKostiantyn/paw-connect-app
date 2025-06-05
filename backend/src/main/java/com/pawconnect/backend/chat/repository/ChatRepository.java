package com.pawconnect.backend.chat.repository;

import com.pawconnect.backend.chat.model.Chat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ChatRepository extends JpaRepository<Chat, Long> {
    boolean existsByIdAndParticipantsUserId(Long id, Long userId);

    List<Chat> findByParticipantsUserId(Long userId);
}
