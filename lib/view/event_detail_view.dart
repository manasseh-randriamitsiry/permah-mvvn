import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/event_repository.dart';
import '../viewmodel/event_detail_viewmodel.dart';
import '../core/utils/app_utils.dart';

class EventDetailView extends StatelessWidget {
  final int eventId;

  const EventDetailView({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventDetailViewModel(
        eventRepository: Provider.of<EventRepository>(context, listen: false),
        eventId: eventId,
      ),
      child: const EventDetailScreen(),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EventDetailViewModel>(context);
    final theme = Theme.of(context);

    if (viewModel.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.error!,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.loadEvent(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final event = viewModel.event;
    if (event == null) {
      return const Scaffold(
        body: Center(child: Text('Event not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.title),
              background: event.imageUrl != null
                  ? Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.event, size: 64),
                      ),
                    )
                  : Container(
                      color: theme.primaryColor.withOpacity(0.1),
                      child: const Icon(Icons.event, size: 64),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(event.description),
                  const SizedBox(height: 24),
                  InfoRow(
                    icon: Icons.location_on,
                    text: event.location,
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.calendar_today,
                    text: 'Start: ${event.startDate.toString().split('.')[0]}',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  InfoRow(
                    icon: Icons.calendar_today,
                    text: 'End: ${event.endDate.toString().split('.')[0]}',
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.people,
                    text: 'Available Places: ${event.availablePlaces}',
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.attach_money,
                    text: event.price > 0 ? '\$${event.price}' : 'Free',
                    theme: theme,
                  ),
                  const SizedBox(height: 32),
                  if (viewModel.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final response = await viewModel.joinEvent();
                              if (context.mounted) {
                                if (response.success) {
                                  AppUtils.showSnackBar(
                                    context,
                                    'Successfully joined the event',
                                  );
                                } else {
                                  AppUtils.showSnackBar(
                                    context,
                                    viewModel.error ?? 'Failed to join event',
                                  );
                                }
                              }
                            },
                            child: const Text('Join Event'),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
