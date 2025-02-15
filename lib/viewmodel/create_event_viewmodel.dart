import 'package:flutter/material.dart';
import '../model/api_response.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';

class CreateEventViewModel extends ChangeNotifier {
  final EventRepository _eventRepository;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController availablePlacesController =
      TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _error;

  CreateEventViewModel({required EventRepository eventRepository})
      : _eventRepository = eventRepository;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void setStartDate(DateTime date) {
    _startDate = date;
    if (_endDate == null || _endDate!.isBefore(date)) {
      _endDate = date.add(const Duration(hours: 2));
    }
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    if (date.isAfter(_startDate ?? date)) {
      _endDate = date;
      notifyListeners();
    } else {
      _error = 'End date must be after start date';
      notifyListeners();
    }
  }

  bool validateInputs() {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        locationController.text.isEmpty ||
        availablePlacesController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      _error = 'All fields are required';
      notifyListeners();
      return false;
    }

    final availablePlaces = int.tryParse(availablePlacesController.text);
    if (availablePlaces == null || availablePlaces <= 0) {
      _error = 'Available places must be a positive number';
      notifyListeners();
      return false;
    }

    final price = double.tryParse(priceController.text);
    if (price == null || price < 0) {
      _error = 'Price must be a non-negative number';
      notifyListeners();
      return false;
    }

    if (_startDate!.isBefore(DateTime.now())) {
      _error = 'Event date must be in the future';
      notifyListeners();
      return false;
    }

    if (_endDate!.isBefore(_startDate!)) {
      _error = 'End date must be after start date';
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<ApiResponse<Event>> createEvent() async {
    if (!validateInputs()) {
      return ApiResponse(
        success: false,
        message: _error ?? 'Invalid input',
        statusCode: 400,
      );
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final event = Event(
        title: titleController.text,
        description: descriptionController.text,
        location: locationController.text,
        startDate: _startDate!,
        endDate: _endDate!,
        availablePlaces: int.parse(availablePlacesController.text),
        price: double.tryParse(priceController.text) ?? 0,
        imageUrl: imageUrlController.text.isEmpty ? 'https://picsum.photos/800/400' : imageUrlController.text,
      );

      final response = await _eventRepository.createEvent(event);
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to create event: ${e.toString()}',
        statusCode: 500,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    availablePlacesController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }
}
