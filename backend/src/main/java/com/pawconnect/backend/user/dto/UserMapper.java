package com.pawconnect.backend.user.dto;

import com.pawconnect.backend.dog.dto.DogMapper;
import com.pawconnect.backend.dog.dto.DogResponse;
import com.pawconnect.backend.match.dto.CandidateUserResponse;
import com.pawconnect.backend.user.model.Language;
import com.pawconnect.backend.user.model.User;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.mapstruct.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.locationtech.jts.geom.Point;
import java.time.LocalDate;
import java.time.Period;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring", uses = {DogMapper.class})
public abstract class UserMapper {

    @Autowired
    protected DogMapper dogMapper;

    private static final GeometryFactory geometryFactory =
            new GeometryFactory(new PrecisionModel(), 4326); // SRID 4326 for GPS coords

    @Mapping(target = "latitude", source = "location", qualifiedByName = "pointToLatitude")
    @Mapping(target = "longitude", source = "location", qualifiedByName = "pointToLongitude")
    @Mapping(target = "languages", expression = "java(mapLanguages(user))")
    @Mapping(target = "dogs", expression = "java(mapDogs(user))")
    public abstract CurrentUserResponse toCurrentUserResponse(User user);

    @Mapping(target = "languages", expression = "java(mapLanguages(user))")
    @Mapping(target = "dogs", expression = "java(mapDogs(user))")
    @Mapping(target = "age", expression = "java(mapAge(user))")
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

    @Mapping(target = "distanceKm", source = "distanceKm")
    @Mapping(target = "languages", expression = "java(mapLanguages(user))")
    @Mapping(target = "dogs", expression = "java(mapDogs(user))")
    public abstract CandidateUserResponse toCandidateUserResponse(User user, Double distanceKm);

    protected Point toPoint(Double longitude, Double latitude) {
        if (latitude != null && longitude != null) {
            return geometryFactory.createPoint(new Coordinate(longitude, latitude));
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

    protected Integer mapAge(User user) {
        LocalDate birthdate = user.getBirthdate();
        return birthdate != null ? Period.between(birthdate, LocalDate.now()).getYears() : null;
    }
}
