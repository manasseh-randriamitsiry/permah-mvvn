import '../model/api_response.dart';
import '../model/event.dart';
import '../model/event_statistics.dart';
import '../model/participant.dart';
import '../core/services/api_service.dart';

class EventRepository {
  final ApiService _apiService;

  EventRepository({required ApiService apiService}) : _apiService = apiService;

  Future<ApiResponse<List<Event>>> getEvents() async {
    final response = await _apiService.getEvents();
    print('Event repository received response: ${response.success}, data: ${response.data}');
    
    if (response.success && response.data != null) {
      try {
        final events = response.data!.map((e) {
          print('Processing event data: $e');
          return Event.fromJson(e);
        }).toList();
        print('Successfully parsed ${events.length} events');
        return ApiResponse.success(events);
      } catch (e) {
        print('Error parsing events: $e');
        return ApiResponse.error('Error parsing events: ${e.toString()}');
      }
    }
    print('Failed to fetch events: ${response.message}');
    return ApiResponse.error(response.message ?? 'Failed to fetch events');
  }

  Future<ApiResponse<Event>> getEvent(int id) async {
    final response = await _apiService.getEvent(id);
    if (response.success && response.data != null) {
      final event = Event.fromJson(response.data!);
      return ApiResponse.success(event);
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch event');
  }

  Future<ApiResponse<Event>> createEvent(Event event) async {
    final response = await _apiService.createEvent(
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      availablePlaces: event.availablePlaces,
      price: event.price,
      imageUrl: event.imageUrl,
    );

    if (response.success && response.data != null) {
      final createdEvent = Event.fromJson(response.data!);
      return ApiResponse.success(createdEvent);
    }
    return ApiResponse.error(response.message ?? 'Failed to create event');
  }

  Future<ApiResponse<Event>> updateEvent(
    int id, {
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    int? availablePlaces,
    double? price,
    String? imageUrl,
  }) async {
    final response = await _apiService.updateEvent(
      id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      location: location,
      availablePlaces: availablePlaces,
      price: price,
      imageUrl: imageUrl.toString(),
    );

    if (response.success && response.data != null) {
      final updatedEvent = Event.fromJson(response.data!);
      return ApiResponse.success(updatedEvent);
    }
    return ApiResponse.error(response.message ?? 'Failed to update event');
  }

  Future<ApiResponse<bool>> deleteEvent(int id) async {
    final response = await _apiService.deleteEvent(id);
    if (response.success) {
      return ApiResponse.success(true);
    }
    return ApiResponse.error(response.message ?? 'Failed to delete event');
  }

  Future<ApiResponse<bool>> joinEvent(int eventId) async {
    final response = await _apiService.joinEvent(eventId);
    if (response.success) {
      return ApiResponse.success(true);
    }
    return ApiResponse.error(response.message ?? 'Failed to join event');
  }

  Future<ApiResponse<bool>> leaveEvent(int eventId) async {
    final response = await _apiService.leaveEvent(eventId);
    if (response.success) {
      return ApiResponse.success(true);
    }
    return ApiResponse.error(response.message ?? 'Failed to leave event');
  }

  Future<ApiResponse<List<Event>>> getUpcomingEvents() async {
    final response = await _apiService.getUpcomingEvents();
    if (response.success && response.data != null) {
      try {
        final events = response.data!.map((e) => Event.fromJson(e)).toList();
        return ApiResponse.success(events);
      } catch (e) {
        return ApiResponse.error('Error parsing upcoming events: ${e.toString()}');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch upcoming events');
  }

  Future<ApiResponse<List<Event>>> getPastEvents() async {
    final response = await _apiService.getPastEvents();
    if (response.success && response.data != null) {
      try {
        final events = response.data!.map((e) => Event.fromJson(e)).toList();
        return ApiResponse.success(events);
      } catch (e) {
        return ApiResponse.error('Error parsing past events: ${e.toString()}');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch past events');
  }

  Future<ApiResponse<List<Event>>> searchEvents({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    double? minPrice,
    double? maxPrice,
    bool? hasAvailablePlaces,
  }) async {
    final response = await _apiService.searchEvents(
      query: query,
      startDate: startDate,
      endDate: endDate,
      location: location,
      minPrice: minPrice,
      maxPrice: maxPrice,
      hasAvailablePlaces: hasAvailablePlaces,
    );
    if (response.success && response.data != null) {
      try {
        final events = response.data!.map((e) => Event.fromJson(e)).toList();
        return ApiResponse.success(events);
      } catch (e) {
        return ApiResponse.error('Error parsing search results: ${e.toString()}');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to search events');
  }

  Future<ApiResponse<EventStatistics>> getEventStatistics(int eventId) async {
    final response = await _apiService.getEventStatistics(eventId);
    if (response.success && response.data != null) {
      try {
        final stats = EventStatistics.fromJson(response.data!);
        return ApiResponse.success(stats);
      } catch (e) {
        return ApiResponse.error('Error parsing event statistics: ${e.toString()}');
      }
    }
    return ApiResponse.error(response.message ?? 'Failed to fetch event statistics');
  }

  Future<ApiResponse<Map<String, dynamic>>> getEventParticipants(int eventId) async {
    try {
      final response = await _apiService.getEventParticipants(eventId);
      if (response.success) {
        return response;
      }
      return ApiResponse.error(response.message ?? 'Failed to fetch event participants');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyCreatedEvents() async {
    try {
      final response = await _apiService.getMyCreatedEvents();
      if (response.success) {
        return response;
      }
      return ApiResponse.error(response.message ?? 'Failed to fetch created events');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMyAttendedEvents() async {
    try {
      final response = await _apiService.getMyAttendedEvents();
      if (response.success) {
        return response;
      }
      return ApiResponse.error(response.message ?? 'Failed to fetch attended events');
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
}
