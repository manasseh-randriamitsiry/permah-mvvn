import 'package:flutter/material.dart';

enum MessageType { error, success, warning, info }

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
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type) {
      case MessageType.error:
        backgroundColor = Colors.red.shade600;
        icon = Icons.error_outline;
        break;
      case MessageType.success:
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case MessageType.warning:
        backgroundColor = Colors.orange.shade600;
        icon = Icons.warning_amber_outlined;
        break;
      case MessageType.info:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
} 