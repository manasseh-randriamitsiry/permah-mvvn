import 'package:flutter/material.dart';
import '../model/event.dart';
import '../model/event_participants.dart';
import '../repository/event_repository.dart';
import 'package:provider/provider.dart';

class EventStatistics extends StatefulWidget {
  final List<Event> events;
  final String currentUserEmail;

  const EventStatistics({
    super.key,
    required this.events,
    required this.currentUserEmail,
  });

  @override
  State<EventStatistics> createState() => _EventStatisticsState();
}

class _EventStatisticsState extends State<EventStatistics> {
  Map<int, int> participantCounts = {};

  @override
  void initState() {
    super.initState();
    _loadParticipantCounts();
  }

  Future<void> _loadParticipantCounts() async {
    final repository = Provider.of<EventRepository>(context, listen: false);
    
    for (final event in widget.events) {
      if (event.id != null) {
        try {
          final response = await repository.getEventParticipants(event.id!);
          if (response.success && response.data != null) {
            print('Event ${event.id} has ${response.data!.totalParticipants} participants and price \$${event.price}');
            setState(() {
              participantCounts[event.id!] = response.data!.totalParticipants;
            });
          }
        } catch (e) {
          print('Error loading participants for event ${event.id}: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final stats = _calculateStats(widget.events, now);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.event_available,
                  title: 'Upcoming',
                  value: stats.upcomingEvents.toString(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.calendar_today,
                  title: 'This Week',
                  value: stats.nextWeekEvents.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.history,
                  title: 'Past',
                  value: stats.pastEvents.toString(),
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  title: 'Participants',
                  value: stats.totalParticipants.toString(),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money,
                  title: 'Total Income',
                  value: '\$${stats.totalIncome.toStringAsFixed(2)}',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _EventStats _calculateStats(List<Event> events, DateTime now) {
    int upcomingEvents = 0;
    int nextWeekEvents = 0;
    int pastEvents = 0;
    int totalParticipants = 0;
    double totalIncome = 0;

    final nextWeek = now.add(const Duration(days: 7));

    for (final event in events) {
      // Calculate event counts based on end date for past events
      if (event.endDate.isAfter(now)) {
        upcomingEvents++;
        if (event.startDate.isBefore(nextWeek)) {
          nextWeekEvents++;
        }
      } else {
        pastEvents++;
      }

      // Calculate income only for events created by the current user
      if (event.id != null && event.isCreator(widget.currentUserEmail)) {
        final participantCount = participantCounts[event.id] ?? 0;
        final eventIncome = participantCount * event.price;
        print('Event ${event.id} income: $participantCount participants × \$${event.price} = \$${eventIncome} (owned by current user)');
        
        totalParticipants += participantCount;
        totalIncome += eventIncome;
      } else if (event.id != null) {
        // Still print info for non-owned events but don't add to total
        final participantCount = participantCounts[event.id] ?? 0;
        final eventIncome = participantCount * event.price;
        print('Event ${event.id} income: $participantCount participants × \$${event.price} = \$${eventIncome} (not owned by current user)');
      }
    }

    print('Total income across owned events: \$${totalIncome}');
    return _EventStats(
      upcomingEvents: upcomingEvents,
      nextWeekEvents: nextWeekEvents,
      pastEvents: pastEvents,
      totalParticipants: totalParticipants,
      totalIncome: totalIncome,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventStats {
  final int upcomingEvents;
  final int nextWeekEvents;
  final int pastEvents;
  final int totalParticipants;
  final double totalIncome;

  _EventStats({
    required this.upcomingEvents,
    required this.nextWeekEvents,
    required this.pastEvents,
    required this.totalParticipants,
    required this.totalIncome,
  });
} 