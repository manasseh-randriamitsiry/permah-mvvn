import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/auth_repository.dart';
import '../viewmodel/login_viewmodel.dart';
import '../widgets/btn_widget.dart';
import '../widgets/input_password_widget.dart';
import '../widgets/input_widget.dart';
import '../common/util.dart';
import '../core/constants/app_constants.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(
        Provider.of<AuthRepository>(context, listen: false),
      ),
      child: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final tablet = isTablet(context);

    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);
    final containerWidth = getContainerWidth(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Login",
          style: TextStyle(fontSize: 25, color: textColor),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.language),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          width: tablet ? 500 : containerWidth,
          child: Stack(
            children: [
              SizedBox(
                width: containerWidth,
                child: Column(
                  children: [
                    SizedBox(height: screenHeight / 20),
                    Text(
                      "Please enter your credentials to login",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: screenHeight / 40),
                    InputWidget(
                      icon: Icons.email_outlined,
                      labelText: 'Email',
                      controller: viewModel.emailController,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    InputPasswordWidget(
                      lblText: "Password",
                      controller: viewModel.passwordController,
                    ),
                    const SizedBox(height: 15),
                    SizedBox(height: screenHeight / 20),
                    if (viewModel.isLoading)
                      const CircularProgressIndicator()
                    else
                      BtnWidget(
                        onTap: () async {
                          if (!viewModel.validateInputs()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(viewModel.error ??
                                    'Please fill all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final success = await viewModel.login();
                          if (success && context.mounted) {
                            Navigator.of(context)
                                .pushReplacementNamed(AppConstants.homeRoute);
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(viewModel.error ?? 'Login failed'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                        inputWidth: containerWidth,
                        inputHeight: screenHeight / 14,
                        text: "LOGIN",
                      ),
                    SizedBox(height: screenHeight / 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: tablet ? screenWidth / 8 : 2 * screenWidth / 8,
                          color: textColor.withOpacity(0.2),
                          height: 2,
                        ),
                        Text("or continue with",
                            style: TextStyle(color: textColor)),
                        Container(
                          width: tablet ? screenWidth / 8 : 2 * screenWidth / 8,
                          color: textColor.withOpacity(0.2),
                          height: 2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight - 115,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Don't have an account?",
                        style: TextStyle(color: textColor)),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(AppConstants.signupRoute);
                      },
                      child: Text(
                        "Register here",
                        style: TextStyle(color: theme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
