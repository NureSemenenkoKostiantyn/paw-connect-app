package com.pawconnect.backend.dog.repository;

import com.pawconnect.backend.dog.model.Dog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DogRepository extends JpaRepository<Dog, Long> {}
