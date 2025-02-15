import 'package:flutter/material.dart';
import '../model/event.dart';

class EventStatistics extends StatelessWidget {
  final List<Event> events;

  const EventStatistics({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final stats = _calculateStats(events, now);

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

      // Calculate participants and income
      // If someone has joined the event (isJoined is true), count them
      if (event.isJoined == true) {
        totalParticipants += 1;
        totalIncome += event.price;
      }
    }

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