import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'event_list_view.dart';
import 'profile_view.dart';
import 'dashboard_view.dart';
import 'create_event_view.dart';
import '../widgets/menu_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  // Getter and setter for currentIndex
  int get currentIndex => _currentIndex;
  set currentIndex(int value) {
    setState(() {
      _currentIndex = value;
    });
  }

  void _handlePageChanged(int index) {
    if (index == 3) {
      // Handle create event navigation
      _drawerController.close?.call();
      Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateEventView(),
        ),
      ).then((result) {
        if (result == true) {
          // If event was created successfully, switch to events list
          setState(() => _currentIndex = 0);
        }
      });
    } else {
      setState(() => _currentIndex = index);
      _drawerController.close?.call();
    }
  }

  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const EventListView();
      case 1:
        return const DashboardView();
      case 2:
        return const ProfileView();
      default:
        return const EventListView();
    }
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Events';
      case 1:
        return 'Dashboard';
      case 2:
        return 'Profile';
      default:
        return 'Events';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _drawerController,
      menuScreen: MenuWidget(
        currentIndex: _currentIndex,
        onPageChanged: _handlePageChanged,
      ),
      mainScreen: Scaffold(
        appBar: AppBar(
          title: Text(_getPageTitle()),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _drawerController.toggle?.call(),
          ),
        ),
        body: _getCurrentPage(),
      ),
      borderRadius: 24,
      showShadow: true,
      angle: 0.0,
      menuBackgroundColor: Theme.of(context).primaryColor,
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.bounceIn,
    );
  }
}
