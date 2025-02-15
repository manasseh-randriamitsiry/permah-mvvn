import 'package:flutter/foundation.dart';
import '../model/api_response.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';
import '../core/services/notification_service.dart';

class EventListViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;
  String? _error;
  List<Event> _events = [];

  EventListViewModel({required EventRepository eventRepository})
      : _eventRepository = eventRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Event> get events => List.unmodifiable(_events);

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('EventListViewModel: Loading events...');
      final response = await _eventRepository.getEvents();
      if (response.success) {
        _events = response.data ?? [];
        _error = null;
        print('EventListViewModel: Successfully loaded ${_events.length} events');
        
        // Schedule notifications for all joined upcoming events
        for (final event in _events) {
          if (event.isJoined == true && event.startDate.isAfter(DateTime.now())) {
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
      notifyListeners();
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
        // Update only the specific event in the list
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          final event = _events[index];
          _events[index] = event.copyWith(
            isJoined: true,
            availablePlaces: event.availablePlaces - 1,
          );
          
          // Schedule notification for the joined event
          if (event.startDate.isAfter(DateTime.now())) {
            await _notificationService.scheduleEventNotification(event);
          }
          
          notifyListeners();
        }
        // Return success even if already joined
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
        // Update only the specific event in the list
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          final event = _events[index];
          _events[index] = event.copyWith(
            isJoined: false,
            availablePlaces: event.availablePlaces + 1,
          );
          
          // Cancel notification for the left event
          await _notificationService.cancelEventNotification(eventId);
          
          notifyListeners();
        }
        // Return success even if not joined
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
