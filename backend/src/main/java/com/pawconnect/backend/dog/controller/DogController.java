package com.pawconnect.backend.dog.controller;

import com.pawconnect.backend.dog.dto.DogCreateRequest;
import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.dog.dto.DogUpdateRequest;
import com.pawconnect.backend.dog.service.DogService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;

@RestController
@RequestMapping("/api/dogs")
public class DogController {
    private final DogService dogService;

    @Autowired
    public DogController(DogService dogService) {
        this.dogService = dogService;
    }

    @PostMapping
    public ResponseEntity<DogResponse> createDog(@Valid @RequestBody DogCreateRequest request) {
        return ResponseEntity.ok(dogService.createDog(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DogResponse> getDogById(@PathVariable Long id) {
        return ResponseEntity.ok(dogService.getDogById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<DogResponse> updateDog(
            @PathVariable Long id,
            @Valid @RequestBody DogUpdateRequest request) {
        return ResponseEntity.ok(dogService.updateDog(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDog(@PathVariable Long id) {
        dogService.deleteDog(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{id}/photos")
    public ResponseEntity<DogResponse> addPhoto(@PathVariable Long id,
                                                @RequestPart("file") MultipartFile file) throws IOException {
        return ResponseEntity.ok(dogService.addPhoto(id, file));
    }

    @DeleteMapping("/{id}/photos")
    public ResponseEntity<Void> deletePhoto(@PathVariable Long id,
                                            @RequestParam("name") String name) {
        dogService.deletePhoto(id, name);
        return ResponseEntity.noContent().build();
    }
}
