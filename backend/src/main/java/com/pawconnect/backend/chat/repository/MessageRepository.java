package com.pawconnect.backend.chat.repository;

import com.pawconnect.backend.chat.model.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    Page<Message> findByChatIdOrderByTimestampDesc(Long chatId, Pageable pageable);

    Message findFirstByChatIdOrderByTimestampDesc(Long chatId);

    int countByChatIdAndIdGreaterThan(Long chatId, Long id);
}
