package com.pawconnect.backend.chat.model;

import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_participants")
@IdClass(ChatParticipantId.class)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatParticipant {

    @Id
    @ManyToOne
    @JoinColumn(name = "chat_id")
    private Chat chat;

    @Id
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
