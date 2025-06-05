package com.pawconnect.backend.chat.controller;

import com.pawconnect.backend.chat.dto.ChatMessageResponse;
import com.pawconnect.backend.chat.service.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chats")
@RequiredArgsConstructor
@Validated
public class ChatRestController {

    private final MessageService messageService;

    @GetMapping("/{chatId}/messages")
    public ResponseEntity<List<ChatMessageResponse>> getMessages(
            @PathVariable Long chatId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(messageService.getMessages(chatId, page, limit));
    }
}
