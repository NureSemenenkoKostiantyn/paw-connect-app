package com.pawconnect.backend.chat.dto;

import com.pawconnect.backend.common.enums.ChatType;
import lombok.Data;

import java.util.List;

@Data
public class ChatResponse {
    private Long id;
    private ChatType type;
    private Long eventId;
    private List<Long> participantIds;
}
