package com.pawconnect.backend.match.service;

import com.pawconnect.backend.match.repository.SwipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class SwipeService {
    private final SwipeRepository swipeRepository;

    @Autowired
    public SwipeService(final SwipeRepository swipeRepository) {
        this.swipeRepository = swipeRepository;
    }
}
