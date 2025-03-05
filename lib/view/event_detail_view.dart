import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../model/event.dart';
import '../viewmodel/event_detail_viewmodel.dart';
import '../repository/event_repository.dart';
import '../repository/auth_repository.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/message_widget.dart';
import '../widgets/loading_button.dart';
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

  void _showMessage(BuildContext context, String message, MessageType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MessageWidget(
          message: message,
          type: type,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EventDetailViewModel>(context);
    final currentUserEmail = Provider.of<AuthRepository>(context, listen: false)
        .currentUser!
        .email;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (viewModel.event != null && viewModel.event!.isCreator(currentUserEmail)) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
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
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showDeleteDialog(context, viewModel),
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
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildEventHeader(context, event),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(height: 300), // Adjust this value to control how much of the image is shown
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEventTitle(context, event),
                            const SizedBox(height: 24),
                            _buildEventInfo(context, event),
                            const SizedBox(height: 24),
                            _buildEventDescription(context, event),
                            const SizedBox(height: 24),
                            _buildEventStats(context, event),
                            const SizedBox(height: 24),
                            if (!event.isCreator(currentUserEmail))
                              _buildActionButton(context, event, viewModel),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventHeader(BuildContext context, Event event) {
    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          if (_isValidImageUrl(event.imageUrl))
            Hero(
              tag: 'event-image-${event.id}',
              child: CachedNetworkImage(
                imageUrl: event.imageUrl,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 350,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 350,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTitle(BuildContext context, Event event) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        if (event.creator != null) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  event.creator!['name'][0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Created by ${event.creator!['name']}',
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEventInfo(BuildContext context, Event event) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.calendar_today,
            text: 'Starts: ${dateFormat.format(event.startDate)} at ${timeFormat.format(event.startDate)}',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today,
            text: 'Ends: ${dateFormat.format(event.endDate)} at ${timeFormat.format(event.endDate)}',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on,
            text: event.location,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildEventDescription(BuildContext context, Event event) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          event.description,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildEventStats(BuildContext context, Event event) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.people,
                  value: event.availablePlaces.toString(),
                  label: 'Available Places',
                  theme: theme,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _StatItem(
                  icon: Icons.attach_money,
                  value: 'Ar ${event.price.toStringAsFixed(2)}',
                  label: 'Price',
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.people_outline),
            label: const Text('View Participants'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventParticipantsView(
                    eventId: event.id,
                    eventTitle: event.title,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Event event, EventDetailViewModel viewModel) {
    return LoadingButton(
      isLoading: viewModel.isLoading,
      text: event.isJoined == true ? 'LEAVE EVENT' : 'JOIN EVENT',
      onPressed: event.isJoined == true
          ? () => _handleLeaveEvent(context, viewModel)
          : () => _handleJoinEvent(context, viewModel),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, EventDetailViewModel viewModel) async {
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
          Navigator.pop(context, true);
          _showMessage(context, 'Event deleted successfully', MessageType.success);
        } else {
          _showMessage(
            context,
            response.message ?? 'Failed to delete event',
            MessageType.error,
          );
        }
      }
    }
  }

  Future<void> _handleJoinEvent(
    BuildContext context,
    EventDetailViewModel viewModel,
  ) async {
    final response = await viewModel.joinEvent();
    if (context.mounted) {
      if (response.success) {
        _showMessage(context, 'Successfully joined the event', MessageType.success);
      } else {
        _showMessage(
          context,
          response.message ?? 'Failed to join event',
          MessageType.error,
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
        _showMessage(context, 'Successfully left the event', MessageType.success);
      } else {
        _showMessage(
          context,
          response.message ?? 'Failed to leave event',
          MessageType.error,
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
