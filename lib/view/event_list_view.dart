import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';
import '../viewmodel/event_list_viewmodel.dart';
import '../core/utils/app_utils.dart';
import '../widgets/event_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import 'create_event_view.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigate to create event screen and wait for result
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventView(),
                ),
              );
              
              // If event was created successfully (result == true), refresh the list
              if (result == true) {
                viewModel.loadEvents();
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: viewModel.loadEvents,
        child: Builder(
          builder: (context) {
            if (viewModel.isLoading) {
              return const LoadingView();
            }

            if (viewModel.error != null) {
              return ErrorView(
                message: viewModel.error!,
                onRetry: viewModel.loadEvents,
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
                  onJoin: () => _handleJoinEvent(context, viewModel, event),
                  onLeave: () => _handleLeaveEvent(context, viewModel, event),
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

  Future<void> _handleJoinEvent(
    BuildContext context,
    EventListViewModel viewModel,
    Event event,
  ) async {
    final response = await viewModel.joinEvent(event.id!);
    if (context.mounted) {
      if (response.success) {
        AppUtils.showSnackBar(context, 'Successfully joined the event');
      } else {
        AppUtils.showSnackBar(
          context,
          viewModel.error ?? 'Failed to join event',
        );
      }
    }
  }

  Future<void> _handleLeaveEvent(
    BuildContext context,
    EventListViewModel viewModel,
    Event event,
  ) async {
    final response = await viewModel.leaveEvent(event.id!);
    if (context.mounted) {
      if (response.success) {
        AppUtils.showSnackBar(context, 'Successfully left the event');
      } else {
        AppUtils.showSnackBar(
          context,
          viewModel.error ?? 'Failed to leave event',
        );
      }
    }
  }
}
