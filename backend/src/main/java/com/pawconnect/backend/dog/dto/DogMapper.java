package com.pawconnect.backend.dog.dto;

import com.pawconnect.backend.dog.model.Dog;
import org.mapstruct.*;
@Mapper(componentModel = "spring")
public interface DogMapper {

    Dog toEntity(DogCreateRequest request);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    void updateDogFromDto(DogUpdateRequest request, @MappingTarget Dog dog);

    @Mapping(source = "owner.id", target = "ownerId")
    DogResponse toDto(Dog dog);
}