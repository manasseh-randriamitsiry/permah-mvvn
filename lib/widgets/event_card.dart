import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
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

  bool _isUpcoming(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUpcoming = _isUpcoming(event.startDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                if (_isValidImageUrl(event.imageUrl))
                  Hero(
                    tag: 'event-image-${event.id}',
                    child: CachedNetworkImage(
                      imageUrl: event.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 160,
                        color: theme.colorScheme.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 160,
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
                Positioned(
                  top: 12,
                  right: 12,
                  child: _StatusChip(isUpcoming: isUpcoming),
                ),
                if (event.creator != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.creator!['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (event.price > 0) ...[
                        const SizedBox(width: 16),
                        _PriceTag(price: event.price),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  _EventInfo(event: event, theme: theme),
                  if (!event.isCreator(currentUserEmail)) ...[
                    const SizedBox(height: 16),
                    _EventActions(
                      event: event,
                      onJoin: onJoin,
                      onLeave: onLeave,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isUpcoming;

  const _StatusChip({required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUpcoming ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isUpcoming ? 'Upcoming' : 'Past',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  final double price;

  const _PriceTag({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '\$${price.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EventInfo extends StatelessWidget {
  final Event event;
  final ThemeData theme;

  const _EventInfo({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Column(
      children: [
        _InfoRow(
          icon: Icons.calendar_today,
          text: '${dateFormat.format(event.startDate)} at ${timeFormat.format(event.startDate)}',
          theme: theme,
        ),
        const SizedBox(height: 8),
        _InfoRow(
          icon: Icons.location_on,
          text: event.location,
          theme: theme,
        ),
        const SizedBox(height: 8),
        _InfoRow(
          icon: Icons.people,
          text: '${event.availablePlaces} spots available',
          theme: theme,
          textColor: event.availablePlaces > 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;
  final Color? textColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.theme,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textColor ?? theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
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
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: event.isJoined == true
              ? OutlinedButton.icon(
                  onPressed: onLeave,
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Leave Event'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: event.availablePlaces > 0 ? onJoin : null,
                  icon: const Icon(Icons.add),
                  label: Text(
                    event.availablePlaces > 0 ? 'Join Event' : 'Event Full',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
        ),
      ],
    );
  }
}
