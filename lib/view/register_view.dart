import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/register_viewmodel.dart';
import '../widgets/btn_widget.dart';
import '../widgets/input_widget.dart';
import '../widgets/input_password_widget.dart';
import '../core/utils/app_utils.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(
        Provider.of<AuthRepository>(context, listen: false),
      ),
      child: const RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: screenHeight * 0.02),
            const Text(
              'Create your account',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.04),
            if (viewModel.error != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                color: theme.colorScheme.error.withOpacity(0.1),
                child: Text(
                  viewModel.error!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: screenHeight * 0.02),
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
            const SizedBox(height: 16),
            InputPasswordWidget(
              lblText: 'Password',
              controller: viewModel.passwordController,
            ),
            const SizedBox(height: 16),
            InputPasswordWidget(
              lblText: 'Confirm Password',
              controller: viewModel.confirmPasswordController,
            ),
            SizedBox(height: screenHeight * 0.04),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              BtnWidget(
                text: 'Register',
                onTap: viewModel.isLoading
                    ? () {}
                    : () => _handleRegister(context),
                inputWidth: MediaQuery.of(context).size.width * 0.8,
                inputHeight: 48,
              ),
            SizedBox(height: screenHeight * 0.02),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  children: [
                    TextSpan(
                      text: 'Login here',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister(BuildContext context) async {
    final viewModel = Provider.of<RegisterViewModel>(context, listen: false);
    final response = await viewModel.register();
    if (context.mounted) {
      if (response.success) {
        Navigator.of(context).pop(); // Return to login screen
        AppUtils.showSnackBar(
          context,
          'Registration successful! Please login.',
        );
      } else {
        AppUtils.showSnackBar(
          context,
          response.message ?? 'Registration failed',
        );
      }
    }
  }
}
