import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/login_viewmodel.dart';
import '../core/constants/app_constants.dart';
import '../widgets/gradient_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_form_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/message_widget.dart';
import '../widgets/loading_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        Provider.of<AuthRepository>(context, listen: false),
        Provider.of<ApiService>(context, listen: false),
      ),
      child: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

  void _showIpHelpDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width * 0.9 < 400 ? size.width * 0.9 : 400.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).primaryColor,
            ),
            const Text('How to Find Your IP Address'),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Container(
          width: maxWidth,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOSInstructions(
                  context,
                  'Windows',
                  '1. Open Command Prompt (cmd)\n'
                  '2. Type "ipconfig"\n'
                  '3. Look for "IPv4 Address" under your network adapter',
                ),
                const SizedBox(height: 16),
                _buildOSInstructions(
                  context,
                  'Mac',
                  '1. Open Terminal\n'
                  '2. Type "ifconfig | grep inet"\n'
                  '3. Look for "inet" followed by your IP',
                ),
                const SizedBox(height: 16),
                _buildOSInstructions(
                  context,
                  'Linux',
                  '1. Open Terminal\n'
                  '2. Type "ip addr" or "ifconfig"\n'
                  '3. Look for "inet" followed by your IP',
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Note:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '• Make sure both devices are on the same network\n'
                  '• The server must be running on port 8000\n'
                  '• Format: xxx.xxx.xxx.xxx:8000',
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildOSInstructions(BuildContext context, String os, String instructions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$os:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          instructions,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                const AuthHeader(
                  icon: Icons.event,
                  title: 'Welcome Back',
                  subtitle: 'Sign in to continue',
                ),
                AuthFormContainer(
                  title: 'Login',
                  children: [
                    CustomTextField(
                      controller: viewModel.emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: viewModel.passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),
                    ExpansionTile(
                      title: Text(
                        'Advanced Settings',
                        style: theme.textTheme.titleMedium,
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: viewModel.customIpController,
                                label: 'Custom IP Address (Optional)',
                                icon: Icons.computer,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.help_outline),
                              onPressed: () => _showIpHelpDialog(context),
                              tooltip: 'How to find your IP address',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Leave empty to use default server',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      isLoading: viewModel.isLoading,
                      text: 'LOGIN',
                      onPressed: () async {
                        if (!viewModel.validateInputs()) {
                          return;
                        }
                        final response = await viewModel.login();
                        if (!context.mounted) return;
                        
                        if (response.success) {
                          Navigator.of(context)
                              .pushReplacementNamed(AppConstants.homeRoute);
                        } else {
                          final message = response.message ?? 'Login failed';
                          final type = message.toLowerCase().contains('already exists')
                              ? MessageType.warning
                              : MessageType.error;
                          _showMessage(context, message, type);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: theme.textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppConstants.signupRoute);
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
