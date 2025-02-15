import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/event.dart';
import '../viewmodel/event_detail_viewmodel.dart';
import '../repository/event_repository.dart';
import '../repository/auth_repository.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../core/utils/app_utils.dart';
import 'edit_event_view.dart';
import 'event_participants_view.dart';

class EventDetailView extends StatelessWidget {
  final int eventId;

  const EventDetailView({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventDetailViewModel(
        eventRepository: Provider.of<EventRepository>(context, listen: false),
        eventId: eventId,
      ),
      child: const EventDetailScreen(),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EventDetailViewModel>(context);
    final currentUserEmail = Provider.of<AuthRepository>(context, listen: false)
        .currentUser!
        .email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (viewModel.event != null && viewModel.event!.isCreator(currentUserEmail)) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditEventView(event: viewModel.event!),
                  ),
                );
                if (result == true) {
                  viewModel.loadEvent();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final shouldDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Event'),
                    content: const Text('Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (shouldDelete == true && context.mounted) {
                  final response = await viewModel.deleteEvent();
                  if (context.mounted) {
                    if (response.success) {
                      Navigator.pop(context, true); // Return to previous screen
                      AppUtils.showSnackBar(context, 'Event deleted successfully');
                    } else {
                      AppUtils.showSnackBar(
                        context,
                        response.message ?? 'Failed to delete event',
                      );
                    }
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const LoadingView();
          }

          if (viewModel.error != null) {
            return ErrorView(
              message: viewModel.error!,
              onRetry: viewModel.loadEvent,
            );
          }

          final event = viewModel.event;
          if (event == null) {
            return const Center(
              child: Text('Event not found'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isValidImageUrl(event.imageUrl))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Hero(
                      tag: 'event-image-${event.id}',
                      child: CachedNetworkImage(
                        imageUrl: event.imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 200,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          debugPrint('Error loading image: $error');
                          return Container(
                            height: 200,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.calendar_today,
                  text: 'Starts: ${_formatDateTime(event.startDate)}',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.calendar_today,
                  text: 'Ends: ${_formatDateTime(event.endDate)}',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.location_on,
                  text: event.location,
                ),
                if (event.creator != null) ...[
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.person,
                    text: 'Created by: ${event.creator!['name']}',
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  event.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.people,
                          text: 'Available Places: ${event.availablePlaces}',
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.attach_money,
                          text: 'Price: \$${event.price.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.people_outline),
                            label: const Text('View Participants'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventParticipantsView(eventId: event.id!),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (event.isCreator(currentUserEmail))
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '',
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                      onPressed: event.isJoined == true
                          ? () => _handleLeaveEvent(context, viewModel)
                          : () => _handleJoinEvent(context, viewModel),
                      child: Text(
                        event.isJoined == true ? 'Leave Event' : 'Join Event',
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleJoinEvent(
    BuildContext context,
    EventDetailViewModel viewModel,
  ) async {
    final response = await viewModel.joinEvent();
    if (context.mounted) {
      if (response.success) {
        AppUtils.showSnackBar(context, 'Successfully joined the event');
      } else {
        AppUtils.showSnackBar(
          context,
          response.message ?? 'Failed to join event',
        );
      }
    }
  }

  Future<void> _handleLeaveEvent(
    BuildContext context,
    EventDetailViewModel viewModel,
  ) async {
    final response = await viewModel.leaveEvent();
    if (context.mounted) {
      if (response.success) {
        AppUtils.showSnackBar(context, 'Successfully left the event');
      } else {
        AppUtils.showSnackBar(
          context,
          response.message ?? 'Failed to leave event',
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
