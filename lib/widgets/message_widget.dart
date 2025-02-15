import 'package:flutter/material.dart';

enum MessageType {
  success,
  warning,
  error,
}

class MessageWidget extends StatelessWidget {
  final String message;
  final MessageType type;

  const MessageWidget({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: _getTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case MessageType.success:
        return Colors.green.withOpacity(0.1);
      case MessageType.warning:
        return Colors.amber.withOpacity(0.1);
      case MessageType.error:
        return Theme.of(context).colorScheme.error.withOpacity(0.1);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (type) {
      case MessageType.success:
        return Colors.green;
      case MessageType.warning:
        return Colors.amber;
      case MessageType.error:
        return Theme.of(context).colorScheme.error;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade700;
      case MessageType.warning:
        return Colors.amber.shade900;
      case MessageType.error:
        return Theme.of(context).colorScheme.error;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.warning:
        return Icons.warning_amber_outlined;
      case MessageType.error:
        return Icons.error_outline;
    }
  }
} 