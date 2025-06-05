package com.pawconnect.backend.chat.service;

import com.pawconnect.backend.chat.dto.ChatCreateRequest;
import com.pawconnect.backend.chat.dto.ChatMapper;
import com.pawconnect.backend.chat.dto.ChatResponse;
import com.pawconnect.backend.chat.model.Chat;
import com.pawconnect.backend.chat.model.ChatParticipant;
import com.pawconnect.backend.chat.repository.ChatRepository;
import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.exception.UnauthorizedAccessException;
import com.pawconnect.backend.common.enums.ChatType;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.UserRepository;
import com.pawconnect.backend.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ChatRepository chatRepository;
    private final UserRepository userRepository;
    private final ChatMapper chatMapper;
    private final UserService userService;

    public ChatResponse createChat(ChatCreateRequest request) {
        Chat chat = chatMapper.toEntity(request);
        chat.setParticipants(new ArrayList<>());

        List<User> users = userRepository.findAllById(request.getParticipantIds());
        if (users.size() != request.getParticipantIds().size()) {
            throw new NotFoundException("One or more users not found");
        }
        for (User u : users) {
            chat.getParticipants().add(ChatParticipant.builder().chat(chat).user(u).build());
        }
        return chatMapper.toDto(chatRepository.save(chat));
    }

    public Chat createPrivateChat(User u1, User u2) {
        Chat chat = Chat.builder()
                .type(ChatType.PRIVATE)
                .participants(new ArrayList<>())
                .build();
        chat.getParticipants().add(ChatParticipant.builder().chat(chat).user(u1).build());
        chat.getParticipants().add(ChatParticipant.builder().chat(chat).user(u2).build());
        return chatRepository.save(chat);
    }

    public Chat getChatEntity(Long id) {
        return chatRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Chat not found"));
    }

    public Chat getChatForUser(Long chatId, Long userId) {
        if (!chatRepository.existsByIdAndParticipantsUserId(chatId, userId)) {
            throw new UnauthorizedAccessException("You are not a participant of this chat");
        }
        return getChatEntity(chatId);
    }

    public List<ChatResponse> getCurrentUserChats() {
        Long userId = userService.getCurrentUserEntity().getId();
        return getChatsByUserId(userId);
    }

    public List<ChatResponse> getChatsByUserId(Long userId) {
        return chatRepository.findByParticipantsUserId(userId)
                .stream()
                .map(chatMapper::toDto)
                .toList();
    }
}
