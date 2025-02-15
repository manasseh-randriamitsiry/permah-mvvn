import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../model/event.dart';
import '../view/event_detail_view.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final String currentUserEmail;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.currentUserEmail,
    required this.onJoin,
    required this.onLeave,
    required this.onTap,
  });

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

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
            if (_isValidImageUrl(event.imageUrl))
              Hero(
                tag: 'event-image-${event.id}',
                child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 100,
                    color: theme.colorScheme.surfaceVariant,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 100,
                    color: theme.colorScheme.surfaceVariant,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EventHeader(event: event, theme: theme),
                  const SizedBox(height: 16),
                  _EventDetails(event: event, theme: theme),
                  const SizedBox(height: 16),
                  if (!event.isCreator(currentUserEmail))
                    _EventActions(
                      event: event,
                      onJoin: onJoin,
                      onLeave: onLeave,
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventHeader extends StatelessWidget {
  final Event event;
  final ThemeData theme;

  const _EventHeader({
    required this.event,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}

class _EventDetails extends StatelessWidget {
  final Event event;
  final ThemeData theme;

  const _EventDetails({
    required this.event,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailRow(
          icon: Icons.location_on,
          text: event.location,
          theme: theme,
        ),
        const SizedBox(height: 8),
        _DetailRow(
          icon: Icons.calendar_today,
          text: '${event.startDate.toString().split(' ')[0]} - ${event.endDate.toString().split(' ')[0]}',
          theme: theme,
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
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const _DetailRow({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.primaryColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EventActions extends StatelessWidget {
  final Event event;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const _EventActions({
    required this.event,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (event.isJoined == true)
            ElevatedButton(
              onPressed: onLeave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Leave Event'),
            )
          else
            ElevatedButton(
              onPressed: event.availablePlaces > 0 ? onJoin : null,
              child: Text(
                event.availablePlaces > 0 ? 'Join Event' : 'Event Full'
              ),
            ),
        ],
      ),
    );
  }
}
