import 'package:flutter/foundation.dart';
import '../model/api_response.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';

class EventListViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
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
      final response = await _eventRepository.getEvents();
      if (response.success) {
        _events = response.data ?? [];
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load events: ${e.toString()}';
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
      if (response.success) {
        await loadEvents(); // Refresh the list after joining
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
      if (response.success) {
        await loadEvents(); // Refresh the list after leaving
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
