package com.pawconnect.backend.event.repository;

import com.pawconnect.backend.event.model.Event;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {
    @Query(value = "SELECT * FROM events e " +
            "WHERE ST_DWithin(e.location, :loc, :radiusM) " +
            "AND e.event_date_time >= :from", nativeQuery = true)
    List<Event> searchEvents(@Param("loc") Point loc,
                             @Param("radiusM") double radiusM,
                             @Param("from") LocalDateTime from);
}
