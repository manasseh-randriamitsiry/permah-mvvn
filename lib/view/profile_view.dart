import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../widgets/input_widget.dart';
import '../widgets/input_password_widget.dart';
import '../core/utils/app_utils.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        Provider.of<AuthRepository>(context, listen: false),
      ),
      child: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);
    final theme = Theme.of(context);

    if (viewModel.user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final success = await viewModel.logout();
              if (context.mounted) {
                if (success) {
                  // Navigate to login screen and clear stack
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                } else {
                  AppUtils.showSnackBar(
                    context,
                    'Failed to logout',
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (viewModel.error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                color: theme.colorScheme.error.withOpacity(0.1),
                child: Text(
                  viewModel.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InputWidget(
              icon: Icons.person_outline,
              labelText: 'Full Name',
              controller: viewModel.nameController,
              type: TextInputType.name,
            ),
            const SizedBox(height: 16),
            InputWidget(
              icon: Icons.email_outlined,
              labelText: 'Email',
              controller: viewModel.emailController,
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final response = await viewModel.updateProfile();
                      if (context.mounted) {
                        if (response.success) {
                          AppUtils.showSnackBar(
                            context,
                            'Profile updated successfully',
                          );
                        } else {
                          AppUtils.showSnackBar(
                            context,
                            response.message ?? 'Failed to update profile',
                          );
                        }
                      }
                    },
              child: const Text('UPDATE PROFILE'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InputPasswordWidget(
              lblText: 'Current Password',
              controller: viewModel.currentPasswordController,
            ),
            const SizedBox(height: 16),
            InputPasswordWidget(
              lblText: 'New Password',
              controller: viewModel.newPasswordController,
            ),
            const SizedBox(height: 16),
            InputPasswordWidget(
              lblText: 'Confirm New Password',
              controller: viewModel.confirmPasswordController,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () async {
                      final response = await viewModel.updateProfile(
                        isChangingPassword: true,
                      );
                      if (context.mounted) {
                        if (response.success) {
                          AppUtils.showSnackBar(
                            context,
                            'Password updated successfully',
                          );
                        } else {
                          AppUtils.showSnackBar(
                            context,
                            response.message ?? 'Failed to update password',
                          );
                        }
                      }
                    },
              child: const Text('CHANGE PASSWORD'),
            ),
          ],
        ),
      ),
    );
  }
}
