import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/event.dart';
import '../repository/event_repository.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/event_list_viewmodel.dart';
import '../core/utils/app_utils.dart';
import '../widgets/event_card.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import 'event_detail_view.dart';

class EventListView extends StatelessWidget {
  const EventListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventListViewModel(
        eventRepository: Provider.of<EventRepository>(context, listen: false),
      ),
      child: const EventListScreen(),
    );
  }
}

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<EventListViewModel>(context, listen: false).initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _getFilteredEvents(List<Event> events, String filter, String search) {
    print('EventListScreen: Filtering ${events.length} events with filter: $filter, search: $search');
    final searchLower = search.toLowerCase();
    var filteredEvents = events.where((event) {
      final matchesSearch = search.isEmpty ||
          event.title.toLowerCase().contains(searchLower) ||
          event.description.toLowerCase().contains(searchLower) ||
          event.location.toLowerCase().contains(searchLower);

      if (!matchesSearch) return false;

      switch (filter) {
        case 'upcoming':
          return event.startDate.isAfter(DateTime.now());
        case 'past':
          return event.startDate.isBefore(DateTime.now());
        case 'joined':
          return event.isJoined == true;
        default:
          return true;
      }
    }).toList();

    // Sort events: upcoming first, sorted by start date
    filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

    print('EventListScreen: Filtered to ${filteredEvents.length} events');
    return filteredEvents;
  }

  Future<void> _navigateToEventDetail(BuildContext context, Event event) async {
    if (!mounted) return;

    try {
      final navigator = Navigator.of(context);
      if (!navigator.mounted) return;

      final result = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => EventDetailView(eventId: event.id!),
          maintainState: true,
        ),
      );

      if (result == true && mounted) {
        Provider.of<EventListViewModel>(context, listen: false).loadEvents();
      }
    } catch (e) {
      print('Navigation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = Provider.of<AuthRepository>(context, listen: false)
        .currentUser!
        .email;

    return Scaffold(
      body: Consumer<EventListViewModel>(
        builder: (context, viewModel, child) {
          print('EventListScreen: Building with ${viewModel.events.length} events, isLoading: ${viewModel.isLoading}, error: ${viewModel.error}');
          
          if (viewModel.isLoading) {
            return const LoadingView();
          }

          if (viewModel.error != null) {
            print('EventListScreen: Showing error: ${viewModel.error}');
            return ErrorView(
              message: viewModel.error!,
              onRetry: viewModel.loadEvents,
            );
          }

          final filteredEvents = _getFilteredEvents(
            viewModel.events,
            _selectedFilter,
            _searchController.text,
          );

          return RefreshIndicator(
            onRefresh: viewModel.loadEvents,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            if (mounted) setState(() {});
                          },
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _FilterChip(
                                label: 'All',
                                selected: _selectedFilter == 'all',
                                onSelected: (selected) {
                                  if (mounted) setState(() => _selectedFilter = 'all');
                                },
                              ),
                              const SizedBox(width: 8),
                              _FilterChip(
                                label: 'Joined',
                                selected: _selectedFilter == 'joined',
                                onSelected: (selected) {
                                  if (mounted) setState(() => _selectedFilter = 'joined');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (filteredEvents.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events found',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = filteredEvents[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: EventCard(
                              event: event,
                              currentUserEmail: currentUserEmail,
                              onJoin: () => _handleJoinEvent(context, viewModel, event),
                              onLeave: () => _handleLeaveEvent(context, viewModel, event),
                              onTap: () => _navigateToEventDetail(context, event),
                            ),
                          );
                        },
                        childCount: filteredEvents.length,
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

  Future<void> _handleJoinEvent(BuildContext context, EventListViewModel viewModel, Event event) async {
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

  Future<void> _handleLeaveEvent(BuildContext context, EventListViewModel viewModel, Event event) async {
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: selected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
