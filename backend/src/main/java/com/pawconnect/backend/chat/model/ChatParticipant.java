package com.pawconnect.backend.chat.model;

import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.chat.model.Message;
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

    @ManyToOne
    @JoinColumn(name = "last_read_message_id")
    private Message lastReadMessage;
}
