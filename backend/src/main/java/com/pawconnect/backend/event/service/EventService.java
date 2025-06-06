package com.pawconnect.backend.event.service;

import com.pawconnect.backend.common.exception.NotFoundException;
import com.pawconnect.backend.common.exception.UnauthorizedAccessException;
import com.pawconnect.backend.common.util.SecurityUtils;
import com.pawconnect.backend.event.dto.EventCreateRequest;
import com.pawconnect.backend.event.dto.EventMapper;
import com.pawconnect.backend.event.dto.EventResponse;
import com.pawconnect.backend.event.model.Event;
import com.pawconnect.backend.event.model.EventParticipant;
import com.pawconnect.backend.event.model.EventParticipantStatus;
import com.pawconnect.backend.event.repository.EventParticipantRepository;
import com.pawconnect.backend.event.repository.EventRepository;
import com.pawconnect.backend.chat.model.Chat;
import com.pawconnect.backend.chat.service.ChatService;
import com.pawconnect.backend.user.model.ERole;
import com.pawconnect.backend.user.model.User;
import com.pawconnect.backend.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.PrecisionModel;
import org.locationtech.jts.geom.Point;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EventService {

    private static final GeometryFactory geometryFactory =
            new GeometryFactory(new PrecisionModel(), 4326);

    private final EventRepository eventRepository;
    private final EventParticipantRepository participantRepository;
    private final EventMapper eventMapper;
    private final UserService userService;
    private final ChatService chatService;

    public EventResponse createEvent(EventCreateRequest req) {
        User host = userService.getCurrentUserEntity();
        Event event = eventMapper.toEntity(req);
        event.setHost(host);
        Event saved = eventRepository.save(event);
        chatService.createGroupChatForEvent(saved);
        return eventMapper.toDto(saved);
    }

    public List<EventResponse> searchEvents(double latitude, double longitude,
                                            double radiusKm,
                                            LocalDateTime from, LocalDateTime to) {
        Point loc = geometryFactory.createPoint(new Coordinate(longitude, latitude));
        List<Event> events = eventRepository.searchEvents(loc, radiusKm * 1000.0, from, to);
        return events.stream().map(eventMapper::toDto).toList();
    }

    public EventResponse getEvent(Long id) {
        Event event = getEventEntity(id);
        return eventMapper.toDto(event);
    }

    private Event getEventEntity(Long id) {
        return eventRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Event not found"));
    }

    public void joinEvent(Long id, EventParticipantStatus status) {
        Event event = getEventEntity(id);
        User user = userService.getCurrentUserEntity();
        if (event.getHost().getId().equals(user.getId())) {
            throw new IllegalStateException("Host cannot join their own event");
        }
        if (!participantRepository.existsByEventIdAndUserId(id, user.getId())) {
            EventParticipant participant = EventParticipant.builder()
                    .event(event)
                    .user(user)
                    .status(status)
                    .build();
            participantRepository.save(participant);
            Chat chat = chatService.getChatByEventId(event.getId());
            chatService.addParticipant(chat, user);
        }
    }

    public void leaveEvent(Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        boolean wasParticipant = participantRepository.existsByEventIdAndUserId(id, userId);
        if (wasParticipant) {
            participantRepository.deleteByEventIdAndUserId(id, userId);
            User user = userService.getCurrentUserEntity();
            Chat chat = chatService.getChatByEventId(id);
            chatService.removeParticipant(chat, user);
        }
    }

    public void deleteEvent(Long id) {
        Event event = getEventEntity(id);
        User current = userService.getCurrentUserEntity();
        boolean isAdmin = current.getRoles().stream()
                .anyMatch(r -> r.getName() == ERole.ROLE_ADMIN);
        if (!event.getHost().getId().equals(current.getId()) && !isAdmin) {
            throw new UnauthorizedAccessException("You cannot delete this event");
        }
        Chat chat = chatService.getChatByEventId(event.getId());
        chatService.deleteChat(chat);
        eventRepository.delete(event);
    }
}
