package com.pawconnect.backend.dog.dto;

import com.pawconnect.backend.common.storage.BlobStorageService;
import com.pawconnect.backend.dog.model.Dog;
import org.mapstruct.*;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public abstract class DogMapper {

    @Autowired
    protected BlobStorageService blobStorageService;

    public abstract Dog toEntity(DogCreateRequest request);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    public abstract void updateDogFromDto(DogUpdateRequest request, @MappingTarget Dog dog);

    @Mapping(source = "owner.id", target = "ownerId")
    @Mapping(target = "photoUrls", expression = "java(toPhotoUrls(dog.getPhotoBlobNames()))")
    public abstract DogResponse toDto(Dog dog);

    protected List<String> toPhotoUrls(List<String> blobs) {
        if (blobs == null) return List.of();
        return blobs.stream()
                .map(blobStorageService::generateReadUrl)
                .collect(Collectors.toList());
    }
}
