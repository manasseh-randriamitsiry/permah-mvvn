import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../repository/auth_repository.dart';
import '../core/constants/app_constants.dart';
import '../view/my_events_view.dart';
import 'server_settings_dialog.dart';

class MenuWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onPageChanged;

  const MenuWidget({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<AuthRepository>(context).currentUser;

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      user?.name[0].toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? '',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.white),
              title: const Text('Events', style: TextStyle(color: Colors.white)),
              selected: currentIndex == 0,
              onTap: () {
                onPageChanged(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event_note, color: Colors.white),
              title: const Text('My Events', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyEventsView(),
                    maintainState: true,
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.dashboard,
              title: 'Dashboard',
              isSelected: currentIndex == 1,
              onTap: () => onPageChanged(1),
            ),
            _MenuItem(
              icon: Icons.person,
              title: 'Profile',
              isSelected: currentIndex == 2,
              onTap: () => onPageChanged(2),
            ),
            _MenuItem(
              icon: Icons.add_circle_outline,
              title: 'Create Event',
              isSelected: false,
              onTap: () => onPageChanged(3),
            ),
            const Divider(color: Colors.white24),
            _MenuItem(
              icon: Icons.dns,
              title: 'Server Settings',
              isSelected: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const ServerSettingsDialog(),
                );
              },
            ),
            _MenuItem(
              icon: themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              title: themeProvider.themeMode == ThemeMode.dark
                  ? 'Light Mode'
                  : 'Dark Mode',
              isSelected: false,
              onTap: () => themeProvider.toggleTheme(),
            ),
            const Spacer(),
            _MenuItem(
              icon: Icons.logout,
              title: 'Logout',
              isSelected: false,
              onTap: () async {
                final authRepository = Provider.of<AuthRepository>(
                  context,
                  listen: false,
                );
                await authRepository.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(
                    AppConstants.loginRoute,
                  );
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimary.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onPrimary.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
} 