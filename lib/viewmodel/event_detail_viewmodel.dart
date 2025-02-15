import 'package:flutter/foundation.dart';
import '../model/api_response.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';

class EventDetailViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
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

  Future<ApiResponse<void>> joinEvent() async {
    try {
      final response = await _eventRepository.joinEvent(eventId);
      if (response.success) {
        await loadEvent(); // Refresh the event details after joining
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

  Future<ApiResponse<void>> leaveEvent() async {
    try {
      final response = await _eventRepository.leaveEvent(eventId);
      if (response.success) {
        await loadEvent(); // Refresh the event details after leaving
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
