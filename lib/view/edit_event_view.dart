import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';
import '../core/utils/app_utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/message_widget.dart';

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
  String? _error;
  late Event _event;
  late EventRepository _eventRepository;

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
    _event = widget.event;
    _eventRepository = Provider.of<EventRepository>(context, listen: false);
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
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          final DateTime fullDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          
          if (isStartDate) {
            _startDate = fullDateTime;
            // Ensure end date is not before start date
            if (_endDate.isBefore(_startDate)) {
              _endDate = _startDate.add(const Duration(hours: 1));
            }
          } else {
            _endDate = fullDateTime;
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
      final participantsResponse = await _eventRepository.getEventParticipants(widget.event.id!);
      if (participantsResponse.success && participantsResponse.data != null) {
        final data = participantsResponse.data!;
        final totalParticipants = data['total_participants'] as int;
        final updatedEvent = widget.event.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          location: _locationController.text,
          availablePlaces: int.parse(_availablePlacesController.text),
          attendeesCount: totalParticipants,
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
          availablePlaces: updatedEvent.availablePlaces,
          price: updatedEvent.price,
          imageUrl: updatedEvent.imageUrl,
          startDate: updatedEvent.startDate,
          endDate: updatedEvent.endDate,
        );

        if (!mounted) return;

        if (response.success) {
          Navigator.pop(context, true);
        } else {
          setState(() => _error = response.message ?? 'Failed to update event');
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'An error occurred while updating the event');
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
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              icon: Icons.title,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              icon: Icons.description,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _locationController,
              label: 'Location',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _availablePlacesController,
                    label: 'Available Places',
                    icon: Icons.people,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    controller: _priceController,
                    label: 'Price',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _imageUrlController,
              label: 'Image URL (optional)',
              icon: Icons.image,
              keyboardType: TextInputType.url,
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
            if (_error != null) ...[
              const SizedBox(height: 16),
              MessageWidget(
                message: _error!,
                type: MessageType.error,
              ),
            ],
            const SizedBox(height: 24),
            LoadingButton(
              isLoading: _isLoading,
              text: 'UPDATE EVENT',
              onPressed: _updateEvent,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
} 