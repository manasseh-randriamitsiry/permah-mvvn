import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/forgot_password_viewmodel.dart';
import '../core/constants/app_constants.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/gradient_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_form_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/message_widget.dart';
import '../widgets/loading_button.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(
        Provider.of<AuthRepository>(context, listen: false),
        Provider.of<ApiService>(context, listen: false),
      ),
      child: const ForgotPasswordScreen(),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
    final viewModel = Provider.of<ForgotPasswordViewModel>(context);

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
                      subtitle: 'Enter your email to reset password',
                    ),
                    Expanded(
                      child: AuthFormContainer(
                        title: 'Reset Password',
                        children: [
                          CustomTextField(
                            controller: viewModel.emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const Spacer(),
                          LoadingButton(
                            isLoading: viewModel.isLoading,
                            text: 'SEND RESET CODE',
                            onPressed: () async {
                              if (!viewModel.validateInputs()) {
                                return;
                              }
                              final response = await viewModel.requestPasswordReset();
                              if (!context.mounted) return;
                              
                              if (response.success) {
                                _showMessage(
                                  context,
                                  'Reset code sent successfully. Please check your email.',
                                  MessageType.success,
                                );
                                Navigator.of(context).pushNamed(
                                  AppConstants.verifyResetCodeRoute,
                                  arguments: viewModel.emailController.text,
                                );
                              } else {
                                final message = response.message ?? 'Failed to send reset code';
                                _showMessage(context, message, MessageType.error);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Remember your password? ',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Login',
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