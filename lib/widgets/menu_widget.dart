import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/auth_repository.dart';

class MenuWidget extends StatelessWidget {
  final ValueChanged<int> onPageChanged;
  final int currentIndex;

  const MenuWidget({
    super.key,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthRepository>(context).currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
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
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MenuItem(
                    icon: Icons.event,
                    title: 'Events',
                    isSelected: currentIndex == 0,
                    onTap: () => onPageChanged(0),
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
                    icon: Icons.add,
                    title: 'Create event',
                    isSelected: currentIndex == 3,
                    onTap: () => onPageChanged(3),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _MenuItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () async {
                  final success = await Provider.of<AuthRepository>(
                    context,
                    listen: false,
                  ).logout();
                  if (success && context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
} 