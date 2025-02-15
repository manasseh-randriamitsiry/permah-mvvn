import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/event_repository.dart';
import '../viewmodel/create_event_viewmodel.dart';
import '../core/utils/app_utils.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/message_widget.dart';

class CreateEventView extends StatelessWidget {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateEventViewModel(
        eventRepository: Provider.of<EventRepository>(context, listen: false),
      ),
      child: const Scaffold(
        body: CreateEventScreen(),
      ),
    );
  }
}

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final viewModel = Provider.of<CreateEventViewModel>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? viewModel.startDate ?? DateTime.now() : viewModel.endDate ?? DateTime.now().add(const Duration(hours: 2)),
      firstDate: isStartDate ? DateTime.now() : viewModel.startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartDate ? viewModel.startDate ?? DateTime.now() : viewModel.endDate ?? DateTime.now().add(const Duration(hours: 2)),
        ),
      );
      if (time != null && mounted) {
        if (isStartDate) {
          viewModel.setStartDate(DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          ));
        } else {
          viewModel.setEndDate(DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateEventViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextField(
                controller: viewModel.titleController,
                label: 'Title',
                icon: Icons.title,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: viewModel.descriptionController,
                label: 'Description',
                icon: Icons.description,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: viewModel.locationController,
                label: 'Location',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: viewModel.availablePlacesController,
                      label: 'Available Places',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: viewModel.priceController,
                      label: 'Price',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: viewModel.imageUrlController,
                label: 'Image URL (optional)',
                icon: Icons.image,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date & Time'),
                subtitle: Text(
                  viewModel.startDate != null
                      ? _formatDateTime(viewModel.startDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('End Date & Time'),
                subtitle: Text(
                  viewModel.endDate != null
                      ? _formatDateTime(viewModel.endDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                MessageWidget(
                  message: viewModel.error!,
                  type: MessageType.error,
                ),
              ],
              const SizedBox(height: 24),
              LoadingButton(
                isLoading: viewModel.isLoading,
                text: 'CREATE EVENT',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await viewModel.createEvent();
                    if (mounted) {
                      if (response.success) {
                        viewModel.resetForm();
                        if (context.mounted) {
                          AppUtils.showSnackBar(
                            context,
                            'Event created successfully',
                          );
                          Navigator.of(context).pop(true);
                        }
                      } else {
                        AppUtils.showSnackBar(
                          context,
                          response.message ?? 'Failed to create event',
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
