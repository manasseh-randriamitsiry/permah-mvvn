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
  List<Event> _searchResults = [];
  EventStatistics? _eventStatistics;
  EventParticipants? _eventParticipants;
  bool _isDisposed = false;
  bool _isInitialized = false;

  EventListViewModel({required EventRepository eventRepository})
      : _eventRepository = eventRepository {
    initialize();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Event> get events => List.unmodifiable(_events);
  List<Event> get searchResults => List.unmodifiable(_searchResults);
  EventStatistics? get eventStatistics => _eventStatistics;
  EventParticipants? get eventParticipants => _eventParticipants;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) return;
    _isInitialized = true;
    await loadEvents();
  }

  Future<void> loadEvents() async {
    if (_isDisposed) return;

    _isLoading = true;
    _error = null;
    _events = []; // Clear existing events before loading
    _safeNotifyListeners();

    try {
      final response = await _eventRepository.getEvents();
      if (_isDisposed) return;

      if (response.success) {
        // Filter for upcoming events and today's events, then sort by date
        final now = DateTime.now();
        _events = (response.data ?? [])
            .where((event) => 
              event.startDate.isAfter(now) || 
              (event.startDate.year == now.year && 
               event.startDate.month == now.month && 
               event.startDate.day == now.day)
            )
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
        
        _error = null;
        
        if (!_isDisposed) {
          for (final event in _events) {
            if (_isDisposed) return;
            if (event.id != null) {
              final index = _events.indexOf(event);
              await _updateEventParticipants(event, index);
            }
          }
          
          // Try to schedule notifications, but don't let failures affect the UI
          try {
            for (final event in _events) {
              if (_isDisposed) return;
              if (event.isJoined == true && event.startDate.isAfter(DateTime.now())) {
                await _notificationService.scheduleEventNotification(event).catchError((e) {
                  return null;
                });
              }
            }
          } catch (e) {
            print('EventListViewModel: Error scheduling notifications: $e');
          }
        }
      } else {
        _error = response.message;
        print('EventListViewModel: Failed to load events: $_error');
      }
    } catch (e) {
      if (!_isDisposed) {
        _error = 'Failed to load events: ${e.toString()}';
        print('EventListViewModel: Error loading events: $_error');
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        print('EventListViewModel: Finished loadEvents(), events: ${_events.length}, error: $_error');
        _safeNotifyListeners();
      }
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
    if (_isDisposed) return;
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
      if (!_isDisposed && response.success) {
        _searchResults = response.data ?? [];
        _safeNotifyListeners();
      }
    } catch (e) {
      print('Error searching events: $e');
    }
  }

  Future<void> loadEventStatistics(int eventId) async {
    if (_isDisposed) return;
    try {
      final response = await _eventRepository.getEventStatistics(eventId);
      if (!_isDisposed && response.success) {
        _eventStatistics = response.data;
        _safeNotifyListeners();
      }
    } catch (e) {
      print('Error loading event statistics: $e');
    }
  }

  Future<void> loadEventParticipants(int eventId) async {
    if (_isDisposed) return;
    try {
      final response = await _eventRepository.getEventParticipants(eventId);
      if (!_isDisposed && response.success && response.data != null) {
        _eventParticipants = EventParticipants.fromJson(response.data!);
        _safeNotifyListeners();
      }
    } catch (e) {
      print('Error loading event participants: $e');
    }
  }

  Future<void> refreshEvents() async {
    if (_isDisposed) return;
    await loadEvents();
  }

  Future<void> _checkJoinStatus(Event event, int index) async {
    if (_isDisposed) return;
    try {
      // Instead of trying to join, we'll use the event's isJoined property
      // This property should be set by the API when fetching events
      if (event.isJoined != null) {
        _events[index] = event.copyWith(isJoined: event.isJoined);
        print('EventListViewModel: Event ${event.id} join status: ${event.isJoined}');
        _safeNotifyListeners();
      }
    } catch (e) {
      print('EventListViewModel: Error checking join status for event ${event.id}: $e');
    }
  }

  Future<ApiResponse<void>> joinEvent(int eventId) async {
    if (_isDisposed) {
      return ApiResponse(
        success: false,
        message: 'View model is disposed',
        statusCode: 500,
      );
    }
    
    try {
      final response = await _eventRepository.joinEvent(eventId);
      
      if (_isDisposed) {
        return ApiResponse(
          success: false,
          message: 'View model is disposed',
          statusCode: 500,
        );
      }
      
      // Handle both success (200) and "already joined" (400) cases
      if (response.success || (response.statusCode == 400 && response.message?.contains('Already joined') == true)) {
        // Update the event's isJoined status in the local list
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          _events[index] = _events[index].copyWith(
            isJoined: true,
            // Only increment attendees count if it's a new join (success case)
            attendeesCount: response.success ? _events[index].attendeesCount + 1 : _events[index].attendeesCount
          );
          _safeNotifyListeners();
        }
        
        // Try to schedule notification, but don't let failure affect the UI
        if (!_isDisposed) {
          try {
            final event = _events.firstWhere((e) => e.id == eventId);
            if (event.startDate.isAfter(DateTime.now())) {
              await _notificationService.scheduleEventNotification(event).catchError((e) {
                print('EventListViewModel: Failed to schedule notification for event $eventId: $e');
                return null;
              });
            }
          } catch (e) {
            print('EventListViewModel: Error scheduling notification for event $eventId: $e');
          }
        }
        
        return ApiResponse.success(null);
      }
      
      // Only return error response for actual errors
      if (response.statusCode == 400 && response.message?.contains('Already joined') == true) {
        return ApiResponse.success(null); // Convert "Already joined" to success
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
    if (_isDisposed) {
      return ApiResponse(
        success: false,
        message: 'View model is disposed',
        statusCode: 500,
      );
    }
    
    try {
      final response = await _eventRepository.leaveEvent(eventId);
      
      if (_isDisposed) {
        return ApiResponse(
          success: false,
          message: 'View model is disposed',
          statusCode: 500,
        );
      }
      
      // Handle both success (200) and "not joined" (400) cases
      if (response.success || (response.statusCode == 400 && response.message?.contains('not joined') == true)) {
        // Update the event's isJoined status in the local list
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          _events[index] = _events[index].copyWith(
            isJoined: false,
            // Only decrement attendees count if it's a successful leave
            attendeesCount: response.success ? _events[index].attendeesCount - 1 : _events[index].attendeesCount
          );
          _safeNotifyListeners();
        }
        
        // Cancel notification for the left event
        if (!_isDisposed) {
          await _notificationService.cancelEventNotification(eventId);
        }
        
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

  Future<void> _updateEventParticipants(Event event, int index) async {
    if (_isDisposed) return;
    try {
      final participantsResponse = await _eventRepository.getEventParticipants(event.id);
      if (!_isDisposed && participantsResponse.success && participantsResponse.data != null) {
        final data = participantsResponse.data!;
        _events[index] = event.copyWith(
          attendeesCount: data['total_participants'] as int,
        );
        print('EventListViewModel: Updated event ${event.id} with ${data['total_participants']} participants');
        _safeNotifyListeners();
      }
    } catch (e) {
      print('EventListViewModel: Error updating participants for event ${event.id}: $e');
    }
  }
}
