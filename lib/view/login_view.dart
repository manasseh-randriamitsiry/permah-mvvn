import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/login_viewmodel.dart';
import '../core/constants/app_constants.dart';
import '../widgets/auth_gradient_background.dart';
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

    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const AuthHeader(
                      icon: Icons.event,
                      title: 'Welcome',
                      subtitle: 'Sign in to continue',
                    ),
                    Expanded(
                      child: AuthFormContainer(
                        title: 'Login',
                        titleTrailing: IconButton(
                          icon: const Icon(
                            Icons.settings,
                            size: 24,
                            color: Colors.black54,
                          ),
                          onPressed: () => _showServerSettings(context),
                          tooltip: 'Server Settings',
                        ),
                        children: [
                          CustomTextField(
                            controller: viewModel.emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          CustomTextField(
                            controller: viewModel.passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppConstants.forgotPasswordRoute);
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Color(0xFF673AB7),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
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
                                _showMessage(context, message, MessageType.error);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppConstants.signupRoute);
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Color(0xFF673AB7),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
