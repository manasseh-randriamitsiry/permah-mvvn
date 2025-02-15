import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/event_list_viewmodel.dart';
import '../widgets/event_statistics.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    // Load events when the dashboard is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventListViewModel>(context, listen: false).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EventListViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
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

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    EventStatistics(events: viewModel.events),
                    // Add more dashboard widgets here in the future
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 