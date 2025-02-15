import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'core/services/api_config_service.dart';
import 'repository/auth_repository.dart';
import 'repository/event_repository.dart';
import 'viewmodel/event_list_viewmodel.dart';
import 'view/login_view.dart';
import 'view/home_view.dart';
import 'view/register_view.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'common/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize API config service
  final apiConfigService = ApiConfigService();
  
  // Initialize ApiService with the config service
  final apiService = ApiService(configService: apiConfigService);

  // Initialize repositories
  final authRepository = await AuthRepository.create(
    baseUrl: apiConfigService.baseUrl,
    apiService: apiService,
  );

  final eventRepository = EventRepository(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: apiConfigService),
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(prefs),
        ),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<EventRepository>.value(value: eventRepository),
        ChangeNotifierProvider(
          create: (context) => EventListViewModel(
            eventRepository: eventRepository,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context);
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Permah',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: authRepository.currentUser == null
              ? AppConstants.loginRoute
              : AppConstants.homeRoute,
          routes: {
            AppConstants.loginRoute: (context) => const LoginView(),
            AppConstants.signupRoute: (context) => const RegisterView(),
            AppConstants.homeRoute: (context) => const HomeView(),
          },
        );
      },
    );
  }
}
