import 'package:flutter/material.dart';
import '../repository/event_repository.dart';
import '../model/participant.dart';

class EventParticipantsViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final int eventId;

  bool _isLoading = false;
  String? _error;
  List<Participant> _participants = [];
  int? _totalParticipants;

  EventParticipantsViewModel(this._eventRepository, this.eventId);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Participant> get participants => _participants;
  int? get totalParticipants => _totalParticipants;

  Future<void> loadParticipants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _eventRepository.getEventParticipants(eventId);
      if (response.success && response.data != null) {
        _participants = (response.data!['participants'] as List)
            .map((p) => Participant.fromJson(p))
            .toList();
        _totalParticipants = response.data!['total_participants'] as int;
      } else {
        _error = response.message ?? 'Failed to load participants';
      }
    } catch (e) {
      _error = 'An error occurred while loading participants';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 