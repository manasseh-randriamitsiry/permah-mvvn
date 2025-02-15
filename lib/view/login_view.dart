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
import '../widgets/server_settings_dialog.dart';

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

  void _showServerSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ServerSettingsDialog(),
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
                  titleTrailing: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _showServerSettings(context),
                    tooltip: 'Server Settings',
                    iconSize: 20,
                  ),
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
