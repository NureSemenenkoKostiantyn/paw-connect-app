package com.pawconnect.backend.chat.controller;

import com.pawconnect.backend.chat.dto.ChatMessageRequest;
import com.pawconnect.backend.chat.dto.ChatMessageResponse;
import com.pawconnect.backend.chat.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatController {

    private final MessageService messageService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.send")
    public void sendMessage(ChatMessageRequest request) {
        ChatMessageResponse msg = messageService.saveMessage(request);
        messagingTemplate.convertAndSend("/topic/chats/" + msg.getChatId(), msg);
    }
}
