package com.pawconnect.backend.user.dto;

import com.pawconnect.backend.user.model.Preference;
import org.mapstruct.*;

@Mapper(componentModel = "spring")
public interface PreferenceMapper {

    PreferenceResponse toDto(Preference preference);

    Preference toEntity(PreferenceUpdateRequest request);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updatePreferenceFromDto(PreferenceUpdateRequest request, @MappingTarget Preference preference);
}
