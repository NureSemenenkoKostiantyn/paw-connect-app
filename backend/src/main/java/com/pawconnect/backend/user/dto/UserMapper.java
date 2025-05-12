package com.pawconnect.backend.user.dto;

import com.pawconnect.backend.dog.dto.DogMapper;
import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.user.model.Language;
import com.pawconnect.backend.user.model.User;
import org.mapstruct.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.geo.Point;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring", uses = {DogMapper.class})
public abstract class UserMapper {

    @Autowired
    protected DogMapper dogMapper;

    @Mapping(target = "latitude", source = "location", qualifiedByName = "pointToLatitude")
    @Mapping(target = "longitude", source = "location", qualifiedByName = "pointToLongitude")
    @Mapping(target = "languages", expression = "java(mapLanguages(user))")
    @Mapping(target = "dogs", expression = "java(mapDogs(user))")
    public abstract CurrentUserResponse toCurrentUserResponse(User user);

    @Mapping(target = "latitude", source = "location", qualifiedByName = "pointToLatitudeNullable")
    @Mapping(target = "longitude", source = "location", qualifiedByName = "pointToLongitudeNullable")
    @Mapping(target = "languages", expression = "java(mapLanguages(user))")
    @Mapping(target = "dogs", expression = "java(mapDogs(user))")
    public abstract PublicUserResponse toPublicUserResponse(User user);

    @Mapping(target = "location", expression = "java(toPoint(request.getLongitude(), request.getLatitude()))")
    @Mapping(target = "languages", ignore = true)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "email", ignore = true)
    @Mapping(target = "username", ignore = true)
    @Mapping(target = "passwordHash", ignore = true)
    @Mapping(target = "roles", ignore = true)
    @Mapping(target = "dogs", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "profilePhotoUrl", ignore = true)
    public abstract void updateUserProfileFromDto(UserUpdateProfileRequest request, @MappingTarget User user);

    protected Point toPoint(Double longitude, Double latitude) {
        if (latitude != null && longitude != null) {
            return new Point(longitude, latitude);
        }
        return null;
    }

    @Named("pointToLatitude")
    protected double mapLatitude(Point point) {
        return point != null ? point.getY() : 0.0;
    }

    @Named("pointToLongitude")
    protected double mapLongitude(Point point) {
        return point != null ? point.getX() : 0.0;
    }

    @Named("pointToLatitudeNullable")
    protected Double mapLatitudeNullable(Point point) {
        return point != null ? point.getY() : null;
    }

    @Named("pointToLongitudeNullable")
    protected Double mapLongitudeNullable(Point point) {
        return point != null ? point.getX() : null;
    }

    protected Set<String> mapLanguages(User user) {
        if (user.getLanguages() == null) return Set.of();
        return user.getLanguages().stream()
                .map(Language::getName)
                .collect(Collectors.toSet());
    }

    protected List<DogResponse> mapDogs(User user) {
        if (user.getDogs() == null) return List.of();
        return user.getDogs().stream()
                .map(dogMapper::toDto)
                .collect(Collectors.toList());
    }
}
