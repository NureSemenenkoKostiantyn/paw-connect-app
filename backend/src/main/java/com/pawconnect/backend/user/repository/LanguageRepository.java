package com.pawconnect.backend.user.repository;

import com.pawconnect.backend.user.model.Language;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;



@Repository
public interface LanguageRepository extends JpaRepository<Language, Long> {
}

