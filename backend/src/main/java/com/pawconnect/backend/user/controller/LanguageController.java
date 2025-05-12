package com.pawconnect.backend.user.controller;

import com.pawconnect.backend.user.model.Language;
import com.pawconnect.backend.user.service.LanguageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/user/languages")
@RequiredArgsConstructor
public class LanguageController {
    private final LanguageService languageService;

    @GetMapping
    public ResponseEntity<List<Language>> getAllLanguages() {
        return ResponseEntity.ok(languageService.getAllLanguages());
    }
}
