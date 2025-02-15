import 'package:flutter/material.dart';

class AuthFormContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? titleTrailing;

  const AuthFormContainer({
    super.key,
    required this.title,
    required this.children,
    this.titleTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (titleTrailing != null) ...[
                  const SizedBox(width: 8),
                  titleTrailing!,
                ],
              ],
            ),
            const SizedBox(height: 32),
            ...children,
          ],
        ),
      ),
    );
  }
} 