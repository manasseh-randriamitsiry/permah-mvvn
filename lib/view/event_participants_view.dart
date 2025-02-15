import 'package:flutter/material.dart';
import '../model/event_participants.dart';
import '../viewmodel/event_list_viewmodel.dart';
import 'package:provider/provider.dart';

class EventParticipantsView extends StatelessWidget {
  final int eventId;

  const EventParticipantsView({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Participants'),
      ),
      body: Consumer<EventListViewModel>(
        builder: (context, viewModel, child) {
          // Load participants when the view is first built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            viewModel.loadEventParticipants(eventId);
          });

          if (viewModel.eventParticipants == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final participants = viewModel.eventParticipants!;

          return Column(
            children: [
              // Event summary card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        participants.eventTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${participants.totalParticipants} Participants',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              // Participants list
              Expanded(
                child: ListView.builder(
                  itemCount: participants.participants.length,
                  itemBuilder: (context, index) {
                    final participant = participants.participants[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(participant.name[0].toUpperCase()),
                      ),
                      title: Text(participant.name),
                      subtitle: Text(participant.email),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 