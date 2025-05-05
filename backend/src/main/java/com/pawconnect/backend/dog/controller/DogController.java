package com.pawconnect.backend.dog.controller;

import com.pawconnect.backend.dog.dto.DogDto;
import com.pawconnect.backend.dog.service.DogService;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;

@RestController
@RequestMapping("/api/dogs")
public class DogController {
    private final DogService dogService;

    @Autowired
    public DogController(DogService dogService) {
        this.dogService = dogService;
    }

    @GetMapping("/{id}")
    public DogDto getDogById(@PathVariable Long id) {
        return dogService.getDogById(id);
    }

    @PostMapping
    public DogDto createDog(@RequestBody DogDto dogDto) {
        return dogService.createDog(dogDto);
    }

    @PutMapping("/{id}")
    public DogDto updateDog(@PathVariable Long id, @RequestBody DogDto dogDto) {
        return dogService.updateDog(id, dogDto);
    }

    @DeleteMapping("/{id}")
    public void deleteDog(@PathVariable Long id) {
        dogService.deleteDog(id);
    }
}
