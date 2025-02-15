import '../model/api_response.dart';
import '../model/event.dart';

class EventRepository {
  final List<Event> _mockEvents = [
    Event(
      id: 1,
      title: 'Test Event 1',
      description: 'This is a test event',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      location: 'Test Location',
      availablePlaces: 10,
      price: 0,
    ),
    Event(
      id: 2,
      title: 'Test Event 2',
      description: 'This is another test event',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 4)),
      location: 'Test Location 2',
      availablePlaces: 20,
      price: 10,
    ),
  ];

  Future<ApiResponse<List<Event>>> getEvents() async {
    return ApiResponse.success(_mockEvents);
  }

  Future<ApiResponse<Event>> getEvent(int id) async {
    final event = _mockEvents.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Event not found'),
    );
    return ApiResponse.success(event);
  }

  Future<ApiResponse<Event>> createEvent(Event event) async {
    final newEvent = Event(
      id: _mockEvents.length + 1,
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      availablePlaces: event.availablePlaces,
      price: event.price,
      imageUrl: event.imageUrl,
    );

    _mockEvents.add(newEvent);
    return ApiResponse.success(newEvent);
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
    final index = _mockEvents.indexWhere((e) => e.id == id);
    if (index == -1) {
      return ApiResponse.error('Event not found');
    }

    final oldEvent = _mockEvents[index];
    final updatedEvent = Event(
      id: id,
      title: title ?? oldEvent.title,
      description: description ?? oldEvent.description,
      startDate: startDate ?? oldEvent.startDate,
      endDate: endDate ?? oldEvent.endDate,
      location: location ?? oldEvent.location,
      availablePlaces: availablePlaces ?? oldEvent.availablePlaces,
      price: price ?? oldEvent.price,
      imageUrl: imageUrl ?? oldEvent.imageUrl,
    );

    _mockEvents[index] = updatedEvent;
    return ApiResponse.success(updatedEvent);
  }

  Future<ApiResponse<bool>> deleteEvent(int id) async {
    _mockEvents.removeWhere((e) => e.id == id);
    return ApiResponse.success(true);
  }

  Future<ApiResponse<bool>> joinEvent(int id) async {
    final index = _mockEvents.indexWhere((e) => e.id == id);
    if (index == -1) {
      return ApiResponse.error('Event not found');
    }

    final event = _mockEvents[index];
    if (event.availablePlaces <= 0) {
      return ApiResponse.error('No available places');
    }

    _mockEvents[index] = Event(
      id: event.id,
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      availablePlaces: event.availablePlaces - 1,
      price: event.price,
      imageUrl: event.imageUrl,
    );

    return ApiResponse.success(true);
  }

  Future<ApiResponse<bool>> leaveEvent(int id) async {
    final index = _mockEvents.indexWhere((e) => e.id == id);
    if (index == -1) {
      return ApiResponse.error('Event not found');
    }

    final event = _mockEvents[index];
    _mockEvents[index] = Event(
      id: event.id,
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      availablePlaces: event.availablePlaces + 1,
      price: event.price,
      imageUrl: event.imageUrl,
    );

    return ApiResponse.success(true);
  }
}
