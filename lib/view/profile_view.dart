import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../core/theme/theme_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_form_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/message_widget.dart';
import '../widgets/loading_button.dart';

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

  void _showMessage(BuildContext context, String message, MessageType type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: MessageWidget(
          message: message,
          type: type,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ProfileViewModel>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    if (viewModel.user == null) {
      return const Center(child: Text('User not found'));
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Stack(
                  children: [
                    Positioned(
                      right: 16,
                      top: 0,
                      child: IconButton(
                        icon: Icon(
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: theme.colorScheme.onPrimary,
                        ),
                        onPressed: () => themeProvider.toggleTheme(),
                      ),
                    ),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: theme.colorScheme.onPrimary,
                            child: Text(
                              viewModel.user?.name[0].toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.user?.email ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                AuthFormContainer(
                  title: 'Basic Information',
                  children: [
                    if (viewModel.error != null)
                      MessageWidget(
                        message: viewModel.error!,
                        type: MessageType.error,
                      ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: viewModel.nameController,
                      label: 'Full Name',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: viewModel.emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Change Password',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: viewModel.currentPasswordController,
                      label: 'Current Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: viewModel.newPasswordController,
                      label: 'New Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: viewModel.confirmPasswordController,
                      label: 'Confirm New Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),
                    LoadingButton(
                      isLoading: viewModel.isLoading,
                      text: 'UPDATE PROFILE',
                      onPressed: () async {
                        final isChangingPassword = viewModel.currentPasswordController.text.isNotEmpty ||
                            viewModel.newPasswordController.text.isNotEmpty ||
                            viewModel.confirmPasswordController.text.isNotEmpty;

                        final response = await viewModel.updateProfile(
                          isChangingPassword: isChangingPassword,
                        );

                        if (!context.mounted) return;

                        if (response.success) {
                          _showMessage(
                            context,
                            'Profile updated successfully',
                            MessageType.success,
                          );
                        } else {
                          _showMessage(
                            context,
                            response.message ?? 'Failed to update profile',
                            MessageType.error,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
