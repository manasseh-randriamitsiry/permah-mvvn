import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../viewmodel/my_events_viewmodel.dart';
import '../repository/event_repository.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/event_card.dart';
import '../model/event.dart';
import '../widgets/menu_widget.dart';
import '../core/constants/app_constants.dart';

class MyEventsView extends StatelessWidget {
  const MyEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyEventsViewModel(
        Provider.of<EventRepository>(context, listen: false),
      ),
      child: const MyEventsScreen(),
    );
  }
}

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load events when the screen is first shown
    Future.microtask(() {
      final viewModel = Provider.of<MyEventsViewModel>(context, listen: false);
      viewModel.loadCreatedEvents();
      viewModel.loadAttendedEvents();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    _drawerController.close?.call();
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, AppConstants.profileRoute);
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, AppConstants.createEventRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: MenuWidget(
        currentIndex: -1,
        onPageChanged: _handlePageChanged,
      ),
      mainScreen: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _drawerController.toggle?.call(),
          ),
          title: const Text('My Events'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Created Events'),
              Tab(text: 'Attended Events'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            CreatedEventsTab(),
            AttendedEventsTab(),
          ],
        ),
      ),
      borderRadius: 24,
      showShadow: true,
      angle: 0.0,
      menuBackgroundColor: Theme.of(context).primaryColor,
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.bounceIn,
    );
  }
}

class CreatedEventsTab extends StatelessWidget {
  const CreatedEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyEventsViewModel>(context);
    final theme = Theme.of(context);

    if (viewModel.isLoadingCreated) {
      return const Center(child: LoadingIndicator());
    }

    if (viewModel.createdError != null) {
      return ErrorView(
        message: viewModel.createdError!,
        onRetry: () => viewModel.loadCreatedEvents(),
      );
    }

    if (viewModel.createdEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No events created yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first event to see it here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadCreatedEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.createdEvents.length,
        itemBuilder: (context, index) {
          final event = viewModel.createdEvents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(
              event: event,
              showParticipants: true,
              onTap: () {
                // Navigate to event details
              },
            ),
          );
        },
      ),
    );
  }
}

class AttendedEventsTab extends StatelessWidget {
  const AttendedEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyEventsViewModel>(context);
    final theme = Theme.of(context);

    if (viewModel.isLoadingAttended) {
      return const Center(child: LoadingIndicator());
    }

    if (viewModel.attendedError != null) {
      return ErrorView(
        message: viewModel.attendedError!,
        onRetry: () => viewModel.loadAttendedEvents(),
      );
    }

    if (viewModel.attendedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No events attended yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join an event to see it here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadAttendedEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.attendedEvents.length,
        itemBuilder: (context, index) {
          final event = viewModel.attendedEvents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EventCard(
              event: event,
              showCreator: true,
              onTap: () {
                // Navigate to event details
              },
            ),
          );
        },
      ),
    );
  }
} 