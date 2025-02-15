import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool isTablet(BuildContext context) {
  final mediaQuery = MediaQuery.of(context);
  final size = mediaQuery.size;
  final diagonal = sqrt(size.width * size.width + size.height * size.height);
  final isTablet = diagonal > 1100.0;
  return isTablet;
}

ThemeData getTheme(BuildContext context) {
  final theme = Theme.of(context);
  return theme;
}

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double getContainerWidth(BuildContext context) {
  return getScreenWidth(context) - 50;
}

double getContainerHeight(BuildContext context) {
  return getScreenHeight(context) - 50;
}

double getContainerHeightWithAppBar(BuildContext context) {
  return getScreenHeight(context) - 100;
}

double getContainerHeightWithAppBarAndFooter(BuildContext context) {
  return getScreenHeight(context) - 150;
}

double getContainerHeightWithAppBarAndFooterAndTabBar(BuildContext context) {
  return getScreenHeight(context) - 200;
}

double getContainerHeightWithAppBarAndTabBar(BuildContext context) {
  return getScreenHeight(context) - 150;
}

double getContainerHeightWithFooter(BuildContext context) {
  return getScreenHeight(context) - 100;
}

double getContainerHeightWithTabBar(BuildContext context) {
  return getScreenHeight(context) - 100;
}

double getContainerHeightWithTabBarAndFooter(BuildContext context) {
  return getScreenHeight(context) - 150;
}

double getContainerHeightWithTabBarAndFooterAndAppBar(BuildContext context) {
  return getScreenHeight(context) - 200;
}

double getContainerHeightWithTabBarAndAppBar(BuildContext context) {
  return getScreenHeight(context) - 150;
}

void getHaptics() async {
  HapticFeedback.lightImpact();
}

void showAlertErrorWidget(BuildContext context, String title, String content) {
  AlertDialog(
    backgroundColor: Theme.of(context).cardColor,
    title: Text(title),
    icon: Icon(
      Icons.error,
      size: 100,
      color: Colors.red.shade500,
    ),
    content: Text(
      content,
      textAlign: TextAlign.center,
    ),
    actions: [
      TextButton(
        onPressed: () => {},
        child: Container(
          padding:
          const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              color: Colors.red.shade500),
          child: const Text('Okay'),
        ),
      ),
    ],
  );
}

void showAlertSuccessWidget(
    BuildContext context, String title, String content) {
  AlertDialog(
    backgroundColor: Theme.of(context).cardColor,
    title: Text(title),
    icon: Icon(
      Icons.check,
      size: 100,
      color: Colors.green.shade500,
    ),
    content: Text(
      content,
      textAlign: TextAlign.center,
    ),
    actions: [
      TextButton(
        onPressed: () => {},
        child: Container(
          padding:
          const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              color: Colors.green.shade500),
          child: const Text('Okay'),
        ),
      ),
    ],
  );
}

