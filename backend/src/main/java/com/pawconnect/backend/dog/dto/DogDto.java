package com.pawconnect.backend.dog.dto;

import com.pawconnect.backend.dog.model.Dog;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class DogDto {
    private Long id;
    private String name;
    private String breed;
    private Integer age;
    private String size;
    private String character;

    public DogDto() {}

    public DogDto(Long id, String name, String breed, Integer age, String size, String character) {
        this.id = id;
        this.name = name;
        this.breed = breed;
        this.age = age;
        this.size = size;
        this.character = character;
    }

    public static DogDto fromEntity(Dog dog) {
        return new DogDto(
                dog.getId(),
                dog.getName(),
                dog.getBreed(),
                dog.getAge(),
                dog.getSize(),
                dog.getCharacter()
        );
    }

    public Dog toEntity() {
        Dog dog = new Dog();
        dog.setId(this.id);
        dog.setName(this.name);
        dog.setBreed(this.breed);
        dog.setAge(this.age);
        dog.setSize(this.size);
        dog.setCharacter(this.character);
        return dog;
    }
}