package com.pawconnect.backend.chat.controller;

import com.pawconnect.backend.chat.dto.ChatMessageRequest;
import com.pawconnect.backend.chat.dto.ChatMessageResponse;
import com.pawconnect.backend.chat.service.MessageService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.messaging.simp.SimpMessagingTemplate;


import static org.mockito.Mockito.*;

import org.springframework.security.core.Authentication;

@ExtendWith(MockitoExtension.class)
class ChatControllerTest {

    @Mock MessageService messageService;
    @Mock SimpMessagingTemplate messagingTemplate;

    @InjectMocks ChatController chatController;

    @Test
    void sendMessage_sendsToChatTopic() {
        ChatMessageRequest req = new ChatMessageRequest();
        req.setChatId(5L);
        ChatMessageResponse resp = new ChatMessageResponse();
        resp.setChatId(5L);
        when(messageService.saveMessage(req)).thenReturn(resp);

        Authentication authentication = mock(Authentication.class);
        chatController.sendMessage(authentication, req);

        verify(messagingTemplate).convertAndSend("/topic/chats/5", resp);
    }
}
