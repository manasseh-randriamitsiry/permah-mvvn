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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
              if (titleTrailing != null) titleTrailing!,
            ],
          ),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }
}