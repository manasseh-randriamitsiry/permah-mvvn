import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';
import '../viewmodel/event_list_viewmodel.dart';
import '../core/utils/app_utils.dart';

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventListViewModel(
        eventRepository: Provider.of<EventRepository>(context, listen: false),
      ),
      child: const EventListScreen(),
    );
  }
}

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EventListViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create event screen
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventView()));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.loadEvents,
        child: Builder(
          builder: (context) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.error != null) {
              return Center(
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
                      onPressed: viewModel.loadEvents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.events.isEmpty) {
              return const Center(
                child: Text('No events found'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: viewModel.events.length,
              itemBuilder: (context, index) {
                final event = viewModel.events[index];
                return EventCard(
                  event: event,
                  onJoin: () async {
                    final response = await viewModel.joinEvent(event.id!);
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
                  onTap: () {
                    // Navigate to event details
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (_) => EventDetailView(eventId: event.id!),
                    // ));
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onJoin;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onJoin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.imageUrl != null)
              Image.network(
                event.imageUrl!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '${event.startDate.toString().split(' ')[0]} - ${event.endDate.toString().split(' ')[0]}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available: ${event.availablePlaces}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        event.price > 0 ? '\$${event.price}' : 'Free',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onJoin,
                      child: const Text('Join Event'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
