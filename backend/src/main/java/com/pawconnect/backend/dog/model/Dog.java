package com.pawconnect.backend.dog.model;
import com.pawconnect.backend.user.model.User;
import jakarta.persistence.*;
import lombok.*;


@Entity
@Table(name = "dogs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Dog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String breed;

    private Integer age;

    private String size;

    private String character; //TO-DO many-to-many

    @ManyToOne
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

}
