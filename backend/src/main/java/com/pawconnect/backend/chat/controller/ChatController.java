package com.pawconnect.backend.chat.controller;

import com.pawconnect.backend.chat.dto.ChatMessageRequest;
import com.pawconnect.backend.chat.dto.ChatMessageResponse;
import com.pawconnect.backend.chat.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
@RequiredArgsConstructor
public class ChatController {

    private final MessageService messageService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.send")
    public void sendMessage(Principal principal, ChatMessageRequest request) {
        if (principal instanceof Authentication authentication) {
            SecurityContextHolder.getContext().setAuthentication(authentication);
        }
        ChatMessageResponse msg = messageService.saveMessage(request);
        messagingTemplate.convertAndSend("/topic/chats/" + msg.getChatId(), msg);
    }
}
