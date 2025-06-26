package com.pawconnect.backend.chat.controller;

import com.pawconnect.backend.chat.dto.ChatMessageResponse;
import com.pawconnect.backend.chat.dto.ChatResponse;
import com.pawconnect.backend.chat.service.MessageService;
import com.pawconnect.backend.chat.service.ChatService;
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
    private final ChatService chatService;

    /**
     * List chats for the currently authenticated user. The returned objects
     * include metadata about the last message and the number of unread
     * messages for that user.
     */
    @GetMapping
    public ResponseEntity<List<ChatResponse>> getCurrentUserChats() {
        List<ChatResponse> chats = chatService.getCurrentUserChats();
        return ResponseEntity.ok(chats);
    }

    @GetMapping("/{chatId}/messages")
    public ResponseEntity<List<ChatMessageResponse>> getMessages(
            @PathVariable Long chatId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(messageService.getMessages(chatId, page, limit));
    }

    @PatchMapping("/{chatId}/read/{messageId}")
    public ResponseEntity<Void> markAsRead(@PathVariable Long chatId, @PathVariable Long messageId) {
        messageService.markAsRead(chatId, messageId);
        return ResponseEntity.noContent().build();
    }
}
