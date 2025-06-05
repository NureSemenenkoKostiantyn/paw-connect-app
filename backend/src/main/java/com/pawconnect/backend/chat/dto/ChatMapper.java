package com.pawconnect.backend.chat.dto;

import com.pawconnect.backend.chat.model.Chat;
import com.pawconnect.backend.chat.model.ChatParticipant;
import org.mapstruct.*;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface ChatMapper {
    Chat toEntity(ChatCreateRequest request);

    @Mapping(source = "event.id", target = "eventId")
    @Mapping(target = "participantIds", expression = "java(mapParticipants(chat.getParticipants()))")
    ChatResponse toDto(Chat chat);

    default List<Long> mapParticipants(List<ChatParticipant> participants) {
        if (participants == null) return List.of();
        return participants.stream().map(p -> p.getUser().getId()).collect(Collectors.toList());
    }
}
