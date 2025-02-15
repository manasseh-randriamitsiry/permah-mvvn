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
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _eventRepository.joinEvent(eventId);
      if (response.success) {
        // Update the local event list to reflect the change
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          final updatedEvent = Event(
            id: _events[index].id,
            title: _events[index].title,
            description: _events[index].description,
            startDate: _events[index].startDate,
            endDate: _events[index].endDate,
            location: _events[index].location,
            availablePlaces: _events[index].availablePlaces - 1,
            price: _events[index].price,
            imageUrl: _events[index].imageUrl,
            isJoined: true,
          );
          _events[index] = updatedEvent;
          notifyListeners();
        }
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<void>> leaveEvent(int eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _eventRepository.leaveEvent(eventId);
      if (response.success) {
        // Update the local event list to reflect the change
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index != -1) {
          final updatedEvent = Event(
            id: _events[index].id,
            title: _events[index].title,
            description: _events[index].description,
            startDate: _events[index].startDate,
            endDate: _events[index].endDate,
            location: _events[index].location,
            availablePlaces: _events[index].availablePlaces + 1,
            price: _events[index].price,
            imageUrl: _events[index].imageUrl,
            isJoined: false,
          );
          _events[index] = updatedEvent;
          notifyListeners();
        }
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
