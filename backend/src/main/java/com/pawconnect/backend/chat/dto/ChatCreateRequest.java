package com.pawconnect.backend.chat.dto;

import com.pawconnect.backend.common.enums.ChatType;
import lombok.Data;

import java.util.List;

@Data
public class ChatCreateRequest {
    private ChatType type;
    private List<Long> participantIds;
    private Long eventId;
}
