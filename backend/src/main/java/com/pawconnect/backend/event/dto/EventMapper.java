package com.pawconnect.backend.event.dto;

import com.pawconnect.backend.event.model.Event;
import com.pawconnect.backend.event.model.EventParticipant;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.locationtech.jts.geom.Point;
import org.mapstruct.*;

import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public abstract class EventMapper {

    private static final GeometryFactory geometryFactory =
            new GeometryFactory(new PrecisionModel(), 4326);

    @Mapping(target = "location", expression = "java(toPoint(request.getLongitude(), request.getLatitude()))")
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "host", ignore = true)
    @Mapping(target = "participants", ignore = true)
    public abstract Event toEntity(EventCreateRequest request);

    @Mapping(source = "host.id", target = "hostId")
    @Mapping(target = "latitude", source = "location", qualifiedByName = "pointToLatitude")
    @Mapping(target = "longitude", source = "location", qualifiedByName = "pointToLongitude")
    @Mapping(target = "participantIds", expression = "java(mapParticipants(event.getParticipants()))")
    public abstract EventResponse toDto(Event event);

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

    protected List<Long> mapParticipants(List<EventParticipant> participants) {
        if (participants == null) return List.of();
        return participants.stream()
                .map(p -> p.getUser().getId())
                .collect(Collectors.toList());
    }
}
