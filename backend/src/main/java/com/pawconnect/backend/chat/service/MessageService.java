package com.pawconnect.backend.chat.service;

import com.pawconnect.backend.chat.dto.ChatMessageRequest;
import com.pawconnect.backend.chat.dto.ChatMessageResponse;
import com.pawconnect.backend.chat.model.Chat;
import com.pawconnect.backend.chat.model.Message;
import com.pawconnect.backend.chat.repository.ChatRepository;
import com.pawconnect.backend.chat.repository.ChatParticipantRepository;
import com.pawconnect.backend.chat.repository.MessageRepository;
import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.exception.UnauthorizedAccessException;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepository messageRepository;
    private final ChatRepository chatRepository;
    private final UserService userService;
    private final ChatParticipantRepository chatParticipantRepository;

    public ChatMessageResponse saveMessage(ChatMessageRequest request) {
        Chat chat = chatRepository.findById(request.getChatId())
                .orElseThrow(() -> new NotFoundException("Chat not found"));
        User sender = userService.getCurrentUserEntity();

        if (!chatRepository.existsByIdAndParticipantsUserId(chat.getId(), sender.getId())) {
            throw new UnauthorizedAccessException("You are not a participant of this chat");
        }

        Message message = Message.builder()
                .chat(chat)
                .sender(sender)
                .content(request.getContent())
                .build();
        Message saved = messageRepository.save(message);

        // Mark the message as read for the sender
        chatParticipantRepository.updateLastReadMessage(chat.getId(), sender.getId(), saved);

        ChatMessageResponse res = new ChatMessageResponse();
        res.setId(saved.getId());
        res.setChatId(chat.getId());
        res.setSenderId(sender.getId());
        res.setContent(saved.getContent());
        res.setTimestamp(saved.getTimestamp());
        return res;
    }

    public List<ChatMessageResponse> getMessages(Long chatId, int page, int limit) {
        Chat chat = chatRepository.findById(chatId)
                .orElseThrow(() -> new NotFoundException("Chat not found"));
        User user = userService.getCurrentUserEntity();

        if (!chatRepository.existsByIdAndParticipantsUserId(chat.getId(), user.getId())) {
            throw new UnauthorizedAccessException("You are not a participant of this chat");
        }

        Pageable pageable = PageRequest.of(page, limit);
        var pageRes = messageRepository.findByChatIdOrderByTimestampDesc(chatId, pageable);
        var messages = pageRes.getContent();

        if (!messages.isEmpty()) {
            chatParticipantRepository.findByChatIdAndUserId(chatId, user.getId())
                    .ifPresent(p -> {
                        p.setLastReadMessage(messages.get(0));
                        chatParticipantRepository.save(p);
                    });
        }

        return messages.stream()
                .map(m -> {
                    ChatMessageResponse dto = new ChatMessageResponse();
                    dto.setId(m.getId());
                    dto.setChatId(chatId);
                    dto.setSenderId(m.getSender().getId());
                    dto.setContent(m.getContent());
                    dto.setTimestamp(m.getTimestamp());
                    return dto;
                })
                .toList();
    }

    public void markAsRead(Long chatId, Long messageId) {
        User user = userService.getCurrentUserEntity();
        if (!chatRepository.existsByIdAndParticipantsUserId(chatId, user.getId())) {
            throw new UnauthorizedAccessException("You are not a participant of this chat");
        }

        Message message = messageRepository.findById(messageId)
                .orElseThrow(() -> new NotFoundException("Message not found"));

        if (!message.getChat().getId().equals(chatId)) {
            throw new NotFoundException("Message not found in this chat");
        }

        chatParticipantRepository.updateLastReadMessage(chatId, user.getId(), message);
    }
}
