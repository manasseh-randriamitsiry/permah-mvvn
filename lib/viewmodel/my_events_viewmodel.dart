import 'package:flutter/material.dart';
import '../repository/event_repository.dart';
import '../model/event.dart';

class MyEventsViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;

  bool _isLoadingCreated = false;
  bool _isLoadingAttended = false;
  String? _createdError;
  String? _attendedError;
  List<Event> _createdEvents = [];
  List<Event> _attendedEvents = [];

  MyEventsViewModel(this._eventRepository);

  bool get isLoadingCreated => _isLoadingCreated;
  bool get isLoadingAttended => _isLoadingAttended;
  String? get createdError => _createdError;
  String? get attendedError => _attendedError;
  List<Event> get createdEvents => _createdEvents;
  List<Event> get attendedEvents => _attendedEvents;

  Future<void> loadCreatedEvents() async {
    _isLoadingCreated = true;
    _createdError = null;
    notifyListeners();

    try {
      final response = await _eventRepository.getMyCreatedEvents();
      if (response.success && response.data != null) {
        _createdEvents = (response.data!['events'] as List)
            .map((e) => Event.fromJson(e))
            .toList();
      } else {
        _createdError = response.message ?? 'Failed to load created events';
      }
    } catch (e) {
      _createdError = 'An error occurred while loading created events';
    } finally {
      _isLoadingCreated = false;
      notifyListeners();
    }
  }

  Future<void> loadAttendedEvents() async {
    _isLoadingAttended = true;
    _attendedError = null;
    notifyListeners();

    try {
      final response = await _eventRepository.getMyAttendedEvents();
      if (response.success && response.data != null) {
        _attendedEvents = (response.data!['events'] as List)
            .map((e) => Event.fromJson(e))
            .toList();
      } else {
        _attendedError = response.message ?? 'Failed to load attended events';
      }
    } catch (e) {
      _attendedError = 'An error occurred while loading attended events';
    } finally {
      _isLoadingAttended = false;
      notifyListeners();
    }
  }
} 