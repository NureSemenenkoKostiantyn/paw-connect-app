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

    /** Most recent message in the chat. */
    private ChatMessageResponse lastMessage;

    /** Number of unread messages for the requesting user. */
    private int unreadCount;
}
