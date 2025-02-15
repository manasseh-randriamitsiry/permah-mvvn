import 'package:flutter/foundation.dart';
import '../model/api_response.dart';
import '../model/event.dart';
import '../model/event_statistics.dart';
import '../model/event_participants.dart';
import '../repository/event_repository.dart';
import '../core/services/notification_service.dart';

class EventListViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  String? _error;
  List<Event> _events = [];
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];
  List<Event> _searchResults = [];
  EventStatistics? _eventStatistics;
  EventParticipants? _eventParticipants;

  EventListViewModel({required EventRepository eventRepository})
      : _eventRepository = eventRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Event> get events => List.unmodifiable(_events);
  List<Event> get upcomingEvents => List.unmodifiable(_upcomingEvents);
  List<Event> get pastEvents => List.unmodifiable(_pastEvents);
  List<Event> get searchResults => List.unmodifiable(_searchResults);
  EventStatistics? get eventStatistics => _eventStatistics;
  EventParticipants? get eventParticipants => _eventParticipants;

  Future<void> loadEvents() async {
    print('EventListViewModel: Starting loadEvents()');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('EventListViewModel: Making API call to load events...');
      final response = await _eventRepository.getEvents();
      if (response.success) {
        _events = response.data ?? [];
        _error = null;
        print('EventListViewModel: Successfully loaded ${_events.length} events');
        
        // Update participant counts for all events
        print('EventListViewModel: Updating participant counts...');
        for (final event in _events) {
          if (event.id != null) {
            print('EventListViewModel: Loading participants for event ${event.id}');
            final participantsResponse = await _eventRepository.getEventParticipants(event.id!);
            if (participantsResponse.success && participantsResponse.data != null) {
              final index = _events.indexWhere((e) => e.id == event.id);
              if (index != -1) {
                _events[index] = event.copyWith(
                  attendeesCount: participantsResponse.data!.totalParticipants,
                );
                print('EventListViewModel: Updated event ${event.id} with ${participantsResponse.data!.totalParticipants} participants');
              }
            } else {
              print('EventListViewModel: Failed to load participants for event ${event.id}: ${participantsResponse.message}');
            }
          }
        }
        
        // Schedule notifications for all joined upcoming events
        print('EventListViewModel: Scheduling notifications for joined upcoming events...');
        for (final event in _events) {
          if (event.isJoined == true && event.startDate.isAfter(DateTime.now())) {
            print('EventListViewModel: Scheduling notification for event ${event.id}');
            await _notificationService.scheduleEventNotification(event);
          }
        }
      } else {
        _error = response.message;
        print('EventListViewModel: Failed to load events: $_error');
      }
    } catch (e) {
      _error = 'Failed to load events: ${e.toString()}';
      print('EventListViewModel: Error loading events: $_error');
    } finally {
      _isLoading = false;
      print('EventListViewModel: Finished loadEvents(), events: ${_events.length}, error: $_error');
      notifyListeners();
    }
  }

  Future<void> loadUpcomingEvents() async {
    try {
      final response = await _eventRepository.getUpcomingEvents();
      if (response.success) {
        _upcomingEvents = response.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading upcoming events: $e');
    }
  }

  Future<void> loadPastEvents() async {
    try {
      final response = await _eventRepository.getPastEvents();
      if (response.success) {
        _pastEvents = response.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading past events: $e');
    }
  }

  Future<void> searchEvents({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    double? minPrice,
    double? maxPrice,
    bool? hasAvailablePlaces,
  }) async {
    try {
      final response = await _eventRepository.searchEvents(
        query: query,
        startDate: startDate,
        endDate: endDate,
        location: location,
        minPrice: minPrice,
        maxPrice: maxPrice,
        hasAvailablePlaces: hasAvailablePlaces,
      );
      if (response.success) {
        _searchResults = response.data ?? [];
        notifyListeners();
      }
    } catch (e) {
      print('Error searching events: $e');
    }
  }

  Future<void> loadEventStatistics(int eventId) async {
    try {
      final response = await _eventRepository.getEventStatistics(eventId);
      if (response.success) {
        _eventStatistics = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading event statistics: $e');
    }
  }

  Future<void> loadEventParticipants(int eventId) async {
    try {
      final response = await _eventRepository.getEventParticipants(eventId);
      if (response.success) {
        _eventParticipants = response.data;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading event participants: $e');
    }
  }

  Future<void> refreshEvents() async {
    await loadEvents();
  }

  Future<ApiResponse<void>> joinEvent(int eventId) async {
    try {
      final response = await _eventRepository.joinEvent(eventId);
      // Update the UI if either the join was successful OR if the user has already joined
      if (response.success || response.message?.contains('Already joined') == true) {
        // Get updated participant count for this event
        final participantsResponse = await _eventRepository.getEventParticipants(eventId);
        
        // Refresh the events list to get updated attendee counts from the server
        await loadEvents();
        
        // Schedule notification for the joined event
        final event = _events.firstWhere((e) => e.id == eventId);
        if (event.startDate.isAfter(DateTime.now())) {
          await _notificationService.scheduleEventNotification(event);
        }
        
        return ApiResponse.success(null);
      }
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to join event: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  Future<ApiResponse<void>> leaveEvent(int eventId) async {
    try {
      final response = await _eventRepository.leaveEvent(eventId);
      // Update the UI if either the leave was successful OR if the user wasn't joined
      if (response.success || response.message?.contains('not joined') == true) {
        // Get updated participant count for this event
        final participantsResponse = await _eventRepository.getEventParticipants(eventId);
        
        // Refresh the events list to get updated attendee counts from the server
        await loadEvents();
        
        // Cancel notification for the left event
        await _notificationService.cancelEventNotification(eventId);
        
        return ApiResponse.success(null);
      }
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to leave event: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
