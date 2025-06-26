package com.pawconnect.backend.chat.service;

import com.pawconnect.backend.chat.dto.ChatCreateRequest;
import com.pawconnect.backend.chat.dto.ChatMapper;
import com.pawconnect.backend.chat.dto.ChatResponse;
import com.pawconnect.backend.chat.dto.ChatMessageResponse;
import com.pawconnect.backend.chat.model.Chat;
import com.pawconnect.backend.chat.model.ChatParticipant;
import com.pawconnect.backend.chat.model.Message;
import com.pawconnect.backend.chat.repository.ChatRepository;
import com.pawconnect.backend.chat.repository.ChatParticipantRepository;
import com.pawconnect.backend.chat.repository.MessageRepository;
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
    private final ChatParticipantRepository chatParticipantRepository;
    private final MessageRepository messageRepository;

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

    public void addParticipant(Chat chat, User user) {
        if (!chatParticipantRepository.existsByChatIdAndUserId(chat.getId(), user.getId())) {
            chatParticipantRepository.save(ChatParticipant.builder()
                    .chat(chat)
                    .user(user)
                    .build());
        }
    }

    public void removeParticipant(Chat chat, User user) {
        chatParticipantRepository.deleteByChatIdAndUserId(chat.getId(), user.getId());
    }

    public void deleteChat(Chat chat) {
        chatRepository.delete(chat);
    }

    public Chat createGroupChatForEvent(com.pawconnect.backend.event.model.Event event) {
        Chat chat = Chat.builder()
                .type(ChatType.GROUP)
                .event(event)
                .participants(new ArrayList<>())
                .build();
        chat.getParticipants().add(ChatParticipant.builder()
                .chat(chat)
                .user(event.getHost())
                .build());
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

    /**
     * Retrieve chat details for the currently authenticated user including
     * latest message metadata and unread count.
     */
    public ChatResponse getChatForCurrentUserDto(Long chatId) {
        Long userId = userService.getCurrentUserEntity().getId();
        Chat chat = getChatForUser(chatId, userId);
        return buildChatResponse(chat, userId);
    }

    public List<ChatResponse> getCurrentUserChats() {
        Long userId = userService.getCurrentUserEntity().getId();
        return getChatsByUserId(userId);
    }

    public List<ChatResponse> getChatsByUserId(Long userId) {
        return chatRepository.findByParticipantsUserId(userId)
                .stream()
                .map(chat -> buildChatResponse(chat, userId))
                .toList();
    }

    private ChatResponse buildChatResponse(Chat chat, Long userId) {
        // Retrieve latest message
        Message last = messageRepository.findFirstByChatIdOrderByTimestampDesc(chat.getId());
        ChatMessageResponse lastDto = null;
        if (last != null) {
            lastDto = new ChatMessageResponse();
            lastDto.setId(last.getId());
            lastDto.setChatId(chat.getId());
            lastDto.setSenderId(last.getSender().getId());
            lastDto.setContent(last.getContent());
            lastDto.setTimestamp(last.getTimestamp());
        }

        // Determine unread message count for the user
        java.util.Optional<ChatParticipant> participantOpt =
                chatParticipantRepository.findByChatIdAndUserId(chat.getId(), userId);
        long lastReadId = participantOpt.flatMap(p ->
                        java.util.Optional.ofNullable(p.getLastReadMessage()).map(Message::getId))
                .orElse(0L);
        int unread = messageRepository.countByChatIdAndIdGreaterThan(chat.getId(), lastReadId);

        ChatResponse dto = chatMapper.toDto(chat, lastDto, unread);

        String title;
        if (chat.getType() == ChatType.GROUP) {
            title = chat.getEvent() != null ? chat.getEvent().getTitle() : "Group Chat";
        } else {
            title = chat.getParticipants().stream()
                    .filter(p -> !p.getUser().getId().equals(userId))
                    .map(p -> p.getUser().getUsername())
                    .findFirst()
                    .orElse("Private Chat");
        }
        dto.setTitle(title);
        return dto;
    }

    public Chat getChatByEventId(Long eventId) {
        return chatRepository.findByEventId(eventId)
                .orElseThrow(() -> new NotFoundException("Chat not found"));
    }
}
