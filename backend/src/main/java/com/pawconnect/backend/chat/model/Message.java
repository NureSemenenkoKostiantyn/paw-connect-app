package com.pawconnect.backend.chat.model;

import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;


@Entity
@Table(name = "messages")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Message {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String content;

    private LocalDateTime timestamp = LocalDateTime.now();

    @ManyToOne
    @JoinColumn(name = "chat_id", nullable = false)
    private Chat chat;

    @ManyToOne
    @JoinColumn(name = "sender_id", nullable = false)
    private User sender;
}
