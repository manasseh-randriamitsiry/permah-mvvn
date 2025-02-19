import 'package:flutter/foundation.dart';
import '../model/api_response.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';
import '../core/services/notification_service.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final NotificationService _notificationService = NotificationService();
  final int eventId;
  bool _isLoading = false;
  String? _error;
  Event? _event;

  EventDetailViewModel({
    required EventRepository eventRepository,
    required this.eventId,
  }) : _eventRepository = eventRepository {
    loadEvent();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  Event? get event => _event;

  Future<void> loadEvent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _eventRepository.getEvent(eventId);
      if (response.success) {
        _event = response.data;
        _error = null;
        
        // Check join status
        await _checkJoinStatus();
        
        // Try to schedule notification if already joined
        if (_event?.isJoined == true && _event?.startDate.isAfter(DateTime.now()) == true) {
          try {
            await _notificationService.scheduleEventNotification(_event!).catchError((e) {
              print('EventDetailViewModel: Failed to schedule notification: $e');
              return null;
            });
          } catch (e) {
            print('EventDetailViewModel: Error scheduling notification: $e');
          }
        }
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load event: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkJoinStatus() async {
    try {
      final response = await _eventRepository.joinEvent(eventId);
      // If we get "Already joined" response, update the event's join status
      if (response.statusCode == 400 && response.message?.contains('Already joined') == true) {
        _event = _event?.copyWith(isJoined: true);
        print('EventDetailViewModel: Event $eventId is already joined');
        notifyListeners();
      }
    } catch (e) {
      print('EventDetailViewModel: Error checking join status: $e');
    }
  }

  Future<ApiResponse<void>> joinEvent() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _eventRepository.joinEvent(eventId);
      print('Join event response status: ${response.statusCode}');
      print('Join event response body: ${response.message}');
      
      // Handle both success (200) and "already joined" (400) cases
      if (response.success || (response.statusCode == 400 && response.message?.contains('Already joined') == true)) {
        // Update the local event state immediately
        if (_event != null) {
          _event = _event!.copyWith(
            isJoined: true,
            // Only increment attendees count if it's a new join (success case)
            attendeesCount: response.success ? _event!.attendeesCount + 1 : _event!.attendeesCount
          );
          notifyListeners();
        }
        
        // Try to schedule notification, but don't let failure affect the UI
        if (_event?.startDate.isAfter(DateTime.now()) == true) {
          try {
            await _notificationService.scheduleEventNotification(_event!).catchError((e) {
              print('EventDetailViewModel: Failed to schedule notification: $e');
              return null;
            });
          } catch (e) {
            print('EventDetailViewModel: Error scheduling notification: $e');
          }
        }
        
        // Return success for both cases
        return ApiResponse.success(null);
      }
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to join event: ${e.toString()}',
        statusCode: 500,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<void>> leaveEvent() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _eventRepository.leaveEvent(eventId);
      
      // Handle both success (200) and "not joined" (400) cases
      if (response.success || (response.statusCode == 400 && response.message?.contains('not joined') == true)) {
        // Update the local event state immediately
        if (_event != null) {
          _event = _event!.copyWith(
            isJoined: false,
            // Only decrement attendees count if it's a successful leave
            attendeesCount: response.success ? _event!.attendeesCount - 1 : _event!.attendeesCount
          );
          notifyListeners();
        }
        
        // Try to cancel notification, but don't let failure affect the UI
        try {
          await _notificationService.cancelEventNotification(eventId);
        } catch (e) {
          print('EventDetailViewModel: Error canceling notification: $e');
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<bool>> deleteEvent() async {
    try {
      final response = await _eventRepository.deleteEvent(eventId);
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to delete event: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}
