package com.pawconnect.backend.chat.dto;

import lombok.Data;

@Data
public class ChatMessageRequest {
    private Long chatId;
    private String content;
}
