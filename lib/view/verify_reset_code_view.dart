import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/verify_reset_code_viewmodel.dart';
import '../core/constants/app_constants.dart';
import '../widgets/auth_gradient_background.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_form_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/message_widget.dart';
import '../widgets/loading_button.dart';

class VerifyResetCodeView extends StatelessWidget {
  const VerifyResetCodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String;
    return ChangeNotifierProvider(
      create: (_) => VerifyResetCodeViewModel(
        Provider.of<AuthRepository>(context, listen: false),
        Provider.of<ApiService>(context, listen: false),
        email,
      ),
      child: const VerifyResetCodeScreen(),
    );
  }
}

class VerifyResetCodeScreen extends StatelessWidget {
  const VerifyResetCodeScreen({super.key});

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
    final viewModel = Provider.of<VerifyResetCodeViewModel>(context);

    return Scaffold(
      body: AuthGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AuthHeader(
                icon: Icons.verified_user_outlined,
                title: 'Verify Code',
                subtitle: 'Enter the code sent to your email',
              ),
              AuthFormContainer(
                title: 'Verification',
                children: [
                  CustomTextField(
                    controller: viewModel.codeController,
                    label: 'Verification Code',
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                  const Spacer(),
                  if (viewModel.error != null)
                    MessageWidget(
                      message: viewModel.error!,
                      type: MessageType.error,
                    ),
                  LoadingButton(
                    isLoading: viewModel.isLoading,
                    text: 'VERIFY CODE',
                    onPressed: () async {
                      if (!viewModel.validateInputs()) {
                        return;
                      }
                      final response = await viewModel.verifyResetCode();
                      if (!context.mounted) return;
                      
                      if (response.success) {
                        _showMessage(
                          context,
                          'Code verified successfully',
                          MessageType.success,
                        );
                        Navigator.of(context).pushNamed(
                          AppConstants.resetPasswordRoute,
                          arguments: {
                            'email': viewModel.email,
                            'code': viewModel.codeController.text,
                          },
                        );
                      } else {
                        final message = response.message ?? 'Invalid verification code';
                        _showMessage(context, message, MessageType.error);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () async {
                      viewModel.setLoading(true);
                      final response = await viewModel.resendCode();
                      if (!context.mounted) return;
                      
                      final message = response.success
                          ? 'Verification code resent successfully'
                          : response.message ?? 'Failed to resend code';
                      final type = response.success
                          ? MessageType.success
                          : MessageType.error;
                      _showMessage(context, message, type);
                    },
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: Color(0xFF673AB7),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
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