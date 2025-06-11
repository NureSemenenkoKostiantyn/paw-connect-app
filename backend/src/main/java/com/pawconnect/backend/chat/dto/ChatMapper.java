package com.pawconnect.backend.chat.dto;

import com.pawconnect.backend.chat.model.Chat;
import com.pawconnect.backend.chat.model.ChatParticipant;
import org.mapstruct.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Mapper for converting chat entities to DTOs.
 */

@Mapper(componentModel = "spring")
public interface ChatMapper {
    Chat toEntity(ChatCreateRequest request);

    @Mapping(source = "event.id", target = "eventId")
    @Mapping(target = "participantIds", expression = "java(mapParticipants(chat.getParticipants()))")
    @Mapping(target = "title", ignore = true)
    ChatResponse toDto(Chat chat);

    /**
     * Convenience method allowing manual setting of the last message and unread count.
     */
    default ChatResponse toDto(Chat chat, ChatMessageResponse lastMessage, int unreadCount) {
        ChatResponse dto = toDto(chat);
        dto.setLastMessage(lastMessage);
        dto.setUnreadCount(unreadCount);
        return dto;
    }

    default List<Long> mapParticipants(List<ChatParticipant> participants) {
        if (participants == null) return List.of();
        return participants.stream().map(p -> p.getUser().getId()).collect(Collectors.toList());
    }
}
