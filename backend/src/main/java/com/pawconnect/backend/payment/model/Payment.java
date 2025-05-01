package com.pawconnect.backend.payment.model;

import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "payments")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double amount;
    private String currency;
    private String status; // paid, refunded

    private LocalDateTime timestamp = LocalDateTime.now();

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;
}
