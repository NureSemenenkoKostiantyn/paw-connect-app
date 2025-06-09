package com.pawconnect.backend.user.service;

import com.pawconnect.backend.user.dto.PreferenceMapper;
import com.pawconnect.backend.user.dto.PreferenceResponse;
import com.pawconnect.backend.user.dto.PreferenceUpdateRequest;
import com.pawconnect.backend.user.model.Preference;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.repository.PreferenceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PreferenceService {

    private final PreferenceRepository preferenceRepository;
    private final PreferenceMapper preferenceMapper;
    private final UserService userService;

    private Preference getOrCreatePreference(User user) {
        return preferenceRepository.findById(user.getId())
                .orElseGet(() -> preferenceRepository.save(
                        Preference.builder().user(user).build()));
    }

    public PreferenceResponse getCurrentPreference() {
        User user = userService.getCurrentUserEntity();
        Preference pref = getOrCreatePreference(user);
        return preferenceMapper.toDto(pref);
    }

    public PreferenceResponse updateCurrentPreference(PreferenceUpdateRequest request) {
        User user = userService.getCurrentUserEntity();
        Preference pref = getOrCreatePreference(user);
        preferenceMapper.updatePreferenceFromDto(request, pref);
        return preferenceMapper.toDto(preferenceRepository.save(pref));
    }

    public void deleteCurrentPreference() {
        User user = userService.getCurrentUserEntity();
        preferenceRepository.deleteById(user.getId());
    }
}
