import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';
import '../core/utils/app_utils.dart';

class EditEventView extends StatefulWidget {
  final Event event;

  const EditEventView({
    super.key,
    required this.event,
  });

  @override
  State<EditEventView> createState() => _EditEventViewState();
}

class _EditEventViewState extends State<EditEventView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _availablePlacesController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _availablePlacesController = TextEditingController(
      text: widget.event.availablePlaces.toString(),
    );
    _priceController = TextEditingController(
      text: widget.event.price.toStringAsFixed(2),
    );
    _imageUrlController = TextEditingController(text: widget.event.imageUrl);
    _startDate = widget.event.startDate;
    _endDate = widget.event.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _availablePlacesController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartDate ? _startDate : _endDate,
        ),
      );
      if (time != null) {
        setState(() {
          if (isStartDate) {
            _startDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              time.hour,
              time.minute,
            );
            // Ensure end date is not before start date
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            _endDate = DateTime(
              picked.year,
              picked.month,
              picked.day,
              time.hour,
              time.minute,
            );
          }
        });
      }
    }
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Get the current participant count from the API
      final repository = Provider.of<EventRepository>(context, listen: false);
      final participantsResponse = await repository.getEventParticipants(widget.event.id!);
      final currentParticipants = participantsResponse.success && participantsResponse.data != null
          ? participantsResponse.data!.totalParticipants
          : widget.event.attendeesCount;

      final updatedEvent = widget.event.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        totalPlaces: int.parse(_availablePlacesController.text),
        attendeesCount: currentParticipants,
        price: double.parse(_priceController.text),
        imageUrl: _imageUrlController.text.isEmpty ? 'https://picsum.photos/800/400' : _imageUrlController.text,
        startDate: _startDate,
        endDate: _endDate,
      );

      final response = await Provider.of<EventRepository>(
        context,
        listen: false,
      ).updateEvent(
        updatedEvent.id!,
        title: updatedEvent.title,
        description: updatedEvent.description,
        location: updatedEvent.location,
        availablePlaces: updatedEvent.totalPlaces,
        price: updatedEvent.price,
        imageUrl: updatedEvent.imageUrl,
        startDate: updatedEvent.startDate,
        endDate: updatedEvent.endDate,
      );

      if (!mounted) return;

      if (response.success) {
        Navigator.pop(context, true);
      } else {
        AppUtils.showSnackBar(
          context,
          response.message ?? 'Failed to update event',
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSnackBar(context, 'An error occurred while updating the event');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _availablePlacesController,
                    decoration: const InputDecoration(
                      labelText: 'Available Places',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter available places';
                      }
                      final places = int.tryParse(value);
                      if (places == null || places < 1) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Date & Time'),
              subtitle: Text(_formatDateTime(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: const Text('End Date & Time'),
              subtitle: Text(_formatDateTime(_endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: _isLoading ? null : _updateEvent,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Update Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 