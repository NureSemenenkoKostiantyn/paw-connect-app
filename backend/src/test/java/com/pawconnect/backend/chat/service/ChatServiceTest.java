package com.pawconnect.backend.chat.service;

import com.pawconnect.backend.chat.dto.ChatCreateRequest;
import com.pawconnect.backend.chat.dto.ChatMapper;
import com.pawconnect.backend.chat.dto.ChatResponse;
import com.pawconnect.backend.chat.model.Chat;
import com.pawconnect.backend.chat.repository.ChatRepository;
import com.pawconnect.backend.common.enums.ChatType;
import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ChatServiceTest {

    @Mock ChatRepository chatRepository;
    @Mock UserRepository userRepository;
    @Mock ChatMapper chatMapper;

    @InjectMocks ChatService chatService;

    private ChatCreateRequest request;
    private Chat chat;
    private ChatResponse response;
    private User user1;
    private User user2;

    @BeforeEach
    void setUp() {
        request = new ChatCreateRequest();
        request.setType(ChatType.PRIVATE);
        request.setParticipantIds(List.of(1L,2L));

        chat = Chat.builder().id(10L).build();
        response = new ChatResponse();
        response.setId(10L);

        user1 = User.builder().id(1L).build();
        user2 = User.builder().id(2L).build();
    }

    @Test
    void createChat_success() {
        when(chatMapper.toEntity(request)).thenReturn(chat);
        when(userRepository.findAllById(List.of(1L,2L))).thenReturn(List.of(user1,user2));
        when(chatRepository.save(chat)).thenReturn(chat);
        when(chatMapper.toDto(chat)).thenReturn(response);

        ChatResponse res = chatService.createChat(request);
        assertEquals(10L, res.getId());
        verify(chatRepository).save(chat);
    }

    @Test
    void createChat_userMissing() {
        when(chatMapper.toEntity(request)).thenReturn(chat);
        when(userRepository.findAllById(any())).thenReturn(List.of(user1));
        assertThrows(NotFoundException.class, () -> chatService.createChat(request));
    }

    @Test
    void getChatEntity_found() {
        when(chatRepository.findById(10L)).thenReturn(Optional.of(chat));
        Chat result = chatService.getChatEntity(10L);
        assertEquals(chat, result);
    }

    @Test
    void getChatEntity_notFound() {
        when(chatRepository.findById(99L)).thenReturn(Optional.empty());
        assertThrows(NotFoundException.class, () -> chatService.getChatEntity(99L));
    }
}
