import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/event_repository.dart';
import '../viewmodel/create_event_viewmodel.dart';
import '../widgets/input_widget.dart';
import '../core/utils/app_utils.dart';

class CreateEventView extends StatelessWidget {
  const CreateEventView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateEventViewModel(
        eventRepository: Provider.of<EventRepository>(context, listen: false),
      ),
      child: const CreateEventScreen(),
    );
  }
}

class CreateEventScreen extends StatelessWidget {
  const CreateEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateEventViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (viewModel.error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                color: theme.colorScheme.error.withOpacity(0.1),
                child: Text(
                  viewModel.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            InputWidget(
              icon: Icons.title,
              labelText: 'Event Title',
              controller: viewModel.titleController,
              type: TextInputType.text,
            ),
            const SizedBox(height: 16),
            InputWidget(
              icon: Icons.description,
              labelText: 'Description',
              controller: viewModel.descriptionController,
              type: TextInputType.multiline,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InputWidget(
              icon: Icons.location_on,
              labelText: 'Location',
              controller: viewModel.locationController,
              type: TextInputType.text,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Start Date'),
                    subtitle: Text(
                      viewModel.startDate?.toString().split('.')[0] ??
                          'Not set',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          viewModel.setStartDate(DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ));
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('End Date'),
                    subtitle: Text(
                      viewModel.endDate?.toString().split('.')[0] ?? 'Not set',
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: viewModel.startDate ?? DateTime.now(),
                        firstDate: viewModel.startDate ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          viewModel.setEndDate(DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          ));
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InputWidget(
              icon: Icons.people,
              labelText: 'Available Places',
              controller: viewModel.availablePlacesController,
              type: TextInputType.number,
            ),
            const SizedBox(height: 16),
            InputWidget(
              icon: Icons.attach_money,
              labelText: 'Price',
              controller: viewModel.priceController,
              type: TextInputType.number,
            ),
            const SizedBox(height: 16),
            InputWidget(
              icon: Icons.image,
              labelText: 'Image URL (Optional)',
              controller: viewModel.imageUrlController,
              type: TextInputType.url,
            ),
            const SizedBox(height: 32),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: () async {
                  final response = await viewModel.createEvent();
                  if (context.mounted) {
                    if (response.success) {
                      Navigator.pop(context, true);
                      AppUtils.showSnackBar(
                        context,
                        'Event created successfully',
                      );
                    } else {
                      AppUtils.showSnackBar(
                        context,
                        response.message ?? 'Failed to create event',
                      );
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('CREATE EVENT'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
