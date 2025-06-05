package com.pawconnect.backend.chat.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ChatMessageResponse {
    private Long id;
    private Long chatId;
    private Long senderId;
    private String content;
    private LocalDateTime timestamp;
}
