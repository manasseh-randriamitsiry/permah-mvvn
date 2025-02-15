import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'repository/auth_repository.dart';
import 'repository/event_repository.dart';
import 'view/login_view.dart';
import 'view/home_view.dart';
import 'view/register_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ApiService
  final apiService = ApiService(baseUrl: AppConstants.apiBaseUrl);

  // Initialize AuthRepository
  final authRepository = await AuthRepository.create(
    baseUrl: AppConstants.apiBaseUrl,
  );

  // Initialize EventRepository
  final eventRepository = EventRepository(apiService: apiService);

  runApp(MyApp(
    authRepository: authRepository,
    eventRepository: eventRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final EventRepository eventRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.eventRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: authRepository),
        Provider<EventRepository>.value(value: eventRepository),
      ],
      child: MaterialApp(
        title: 'Permah',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: authRepository.currentUser == null ? '/login' : '/home',
        routes: {
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/home': (context) => const HomeView(),
        },
      ),
    );
  }
}
