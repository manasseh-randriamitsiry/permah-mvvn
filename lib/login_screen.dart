import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permah/widgets/btn_widget.dart';
import 'package:permah/widgets/input_password_widget.dart';
import 'package:permah/widgets/input_widget.dart';
import 'common/util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final backgroundColor = theme.scaffoldBackgroundColor;
    bool tablet = isTablet(context);

    double screenWidth = getScreenWidth(context);
    double screenHeight = getScreenHeight(context);
    double containerWidth = getContainerWidth(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "login_message",
          style: TextStyle(fontSize: 25, color: textColor),
        ),
        leading: IconButton(
          onPressed: () {

          },
          icon: Icon(Icons.language),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: tablet ? 500 : containerWidth,
          child: Stack(
            children: [
              SizedBox(
                width: containerWidth,
                child: Column(
                  children: [
                    SizedBox(height: screenHeight / 20),
                    Text(
                      "login_hint_message",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(height: screenHeight / 40),
                    InputWidget(
                      icon: Icons.email_outlined,
                      labelText: 'enter_id',
                      controller: _usernameController,
                      type: TextInputType.text,
                    ),
                    const SizedBox(height: 15),
                    InputPasswordWidget(
                      lblText: "enter_password",
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                      ],
                    ),
                    SizedBox(height: screenHeight / 20),
                    BtnWidget(
                      onTap: () {
                        if (_usernameController.text.trim().isEmpty ||
                            _passwordController.text.trim().isEmpty) {
                          showAlertErrorWidget(
                              context, "error", "fill_fields");
                        } else {
                          try {
                          } catch (e) {
                            if (kDebugMode) {
                              print(e.toString());
                            }
                          }
                        }
                      },
                      inputWidth: containerWidth,
                      inputHeight: screenHeight / 14,
                      text: "login".toUpperCase(),
                    ),
                    SizedBox(height: screenHeight / 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: isTablet(context)
                              ? screenWidth / 8
                              : 2 * screenWidth / 8,
                          color: textColor.withOpacity(0.2),
                          height: 2,
                        ),
                        Text("continue_with",
                            style: TextStyle(color: textColor)),
                        Container(
                          width: isTablet(context)
                              ? screenWidth / 8
                              : 2 * screenWidth / 8,
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
                    Text("dont_have_account",
                        style: TextStyle(color: textColor)),
                    GestureDetector(
                      onTap: () {

                      },
                      child: Text(
                        "register_here",
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
