import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  String _username = "";

  @override
  void initState() {
    super.initState();
  }


  void _setSystemUiOverlayStyle(bool isDarkMode) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth >= 1200;
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(isDesktop ? 30 : 30),
      ),
      child: Drawer(
        width: isDesktop ? 300 : (4 * screenWidth / 5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              accountEmail: const Text(
                'user_email_from_wpapi@gmail.com',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              decoration: const BoxDecoration(color: Colors.transparent),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/avatar-5.jpg'),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.brightness_6,
                color: Colors.white,
              ),
              title: Text(
                'change_theme',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Icon(
                Icons.subscriptions,
                color: Colors.white,
              ),
              title: Text(
                'subscriptions',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {

              },
            ),
            ListTile(
              leading: const Icon(
                Icons.language,
                color: Colors.white,
              ),
              title: Text(
                'language',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.power_settings_new,
                color: Colors.white,
              ),
              title: Text(
                'logout',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}
