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
          child: Column(
            children: [
              const AuthHeader(
                icon: Icons.lock_reset,
                title: 'Reset Password',
                subtitle: 'Enter your new password',
              ),
              AuthFormContainer(
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
                  if (viewModel.error != null)
                    MessageWidget(
                      message: viewModel.error!,
                      type: MessageType.error,
                    ),
                  LoadingButton(
                    isLoading: viewModel.isLoading,
                    text: 'RESET PASSWORD',
                    onPressed: () async {
                      if (!viewModel.validateInputs()) {
                        return;
                      }
                      final response = await viewModel.resetPassword();
                      if (!context.mounted) return;
                      
                      if (response.success) {
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
                        final message = response.message ?? 'Failed to reset password';
                        _showMessage(context, message, MessageType.error);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 