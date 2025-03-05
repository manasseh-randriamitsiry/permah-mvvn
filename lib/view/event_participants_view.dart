import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/event_participants_viewmodel.dart';
import '../repository/event_repository.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';

class EventParticipantsView extends StatelessWidget {
  final int eventId;
  final String eventTitle;

  const EventParticipantsView({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventParticipantsViewModel(
        Provider.of<EventRepository>(context, listen: false),
        eventId,
      ),
      child: EventParticipantsScreen(eventTitle: eventTitle),
    );
  }
}

class EventParticipantsScreen extends StatefulWidget {
  final String eventTitle;

  const EventParticipantsScreen({
    super.key,
    required this.eventTitle,
  });

  @override
  State<EventParticipantsScreen> createState() => _EventParticipantsScreenState();
}

class _EventParticipantsScreenState extends State<EventParticipantsScreen> {
  @override
  void initState() {
    super.initState();
    // Load participants when the screen is first shown
    Future.microtask(() =>
        Provider.of<EventParticipantsViewModel>(context, listen: false)
            .loadParticipants());
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EventParticipantsViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventTitle),
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (viewModel.error != null) {
            return ErrorView(
              message: viewModel.error!,
              onRetry: () => viewModel.loadParticipants(),
            );
          }

          if (viewModel.participants.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No participants yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.participants.length,
            itemBuilder: (context, index) {
              final participant = viewModel.participants[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      participant.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    participant.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    participant.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 