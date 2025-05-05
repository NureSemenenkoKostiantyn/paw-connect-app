package com.pawconnect.backend.dog.service;

import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.dog.dto.DogDto;
import com.pawconnect.backend.dog.model.Dog;
import com.pawconnect.backend.dog.repository.DogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class DogService {

    private final DogRepository dogRepository;

    @Autowired
    public DogService(DogRepository dogRepository) {
        this.dogRepository = dogRepository;
    }

    public List<DogDto> getAllDogs() {
        return dogRepository.findAll().stream().map(DogDto::fromEntity).collect(Collectors.toList());
    }

    public DogDto getDogById(Long id) {
        return dogRepository.findById(id)
                .map(DogDto::fromEntity)
                .orElseThrow(() -> new NotFoundException("Dog", id));
    }

    public DogDto createDog(DogDto dogDto) {
        Dog saved = dogRepository.save(dogDto.toEntity());
        return DogDto.fromEntity(saved);
    }

    public DogDto updateDog(Long id, DogDto updatedDto) {
        Dog dog = dogRepository.findById(id).orElseThrow(() -> new NotFoundException("Dog", id));
        dog.setName(updatedDto.getName());
        dog.setBreed(updatedDto.getBreed());
        dog.setAge(updatedDto.getAge());
        dog.setSize(updatedDto.getSize());
        dog.setCharacter(updatedDto.getCharacter());
        return DogDto.fromEntity(dogRepository.save(dog));
    }

    public void deleteDog(Long id) {
        dogRepository.deleteById(id);
    }
}

