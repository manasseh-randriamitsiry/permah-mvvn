import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/reset_password_viewmodel.dart';
import '../core/constants/app_constants.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_form_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/message_widget.dart';
import '../widgets/loading_button.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>;
    print('ResetPasswordView arguments:');
    print('Email: ${args['email']}');
    print('Code length: ${args['code']?.length}');
    print('Code: ${args['code']}');
    
    return ChangeNotifierProvider(
      create: (_) => ResetPasswordViewModel(
        Provider.of<AuthRepository>(context, listen: false),
        Provider.of<ApiService>(context, listen: false),
        args['email']!,
        args['code']!,
      ),
      child: const ResetPasswordScreen(),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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
    final viewModel = Provider.of<ResetPasswordViewModel>(context);

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
                      icon: Icons.lock_reset,
                      title: 'Reset Password',
                      subtitle: 'Enter your new password',
                    ),
                    Expanded(
                      child: AuthFormContainer(
                        title: 'New Password',
                        children: [
                          CustomTextField(
                            controller: viewModel.passwordController,
                            label: 'New Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: viewModel.confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const Spacer(),
                          LoadingButton(
                            isLoading: viewModel.isLoading,
                            text: 'RESET PASSWORD',
                            onPressed: () async {
                              print('Reset password button pressed');
                              if (!viewModel.validateInputs()) {
                                print('Password validation failed');
                                _showMessage(
                                  context,
                                  viewModel.error ?? 'Password validation failed',
                                  MessageType.error,
                                );
                                return;
                              }
                              print('Starting password reset process from UI');
                              final response = await viewModel.resetPassword();
                              if (!context.mounted) return;
                              
                              if (response.success) {
                                print('Password reset successful, navigating to login');
                                _showMessage(
                                  context,
                                  'Password reset successfully. Please login with your new password.',
                                  MessageType.success,
                                );
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  AppConstants.loginRoute,
                                  (route) => false,
                                );
                              } else {
                                print('Password reset failed: ${response.message}');
                                _showMessage(
                                  context,
                                  response.message ?? 'Failed to reset password. Please try again.',
                                  MessageType.error,
                                );
                              }
                            },
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