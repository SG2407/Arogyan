import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/theme_provider.dart';
import 'package:aarogyan/screens/common/splash_screen.dart';
import 'package:aarogyan/screens/auth/login_screen.dart';
import 'package:aarogyan/screens/auth/signup_screen.dart';
import 'package:aarogyan/screens/doctor/doctor_dashboard.dart';
import 'package:aarogyan/screens/patient/patient_home.dart';
import 'package:aarogyan/screens/patient/diet_agent_screen.dart';
import 'package:aarogyan/screens/patient/fitness_agent_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aarogyan/services/local_db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize local on-device DB
  await LocalDb.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const AarogyanApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/doctor',
      builder: (context, state) => const DoctorDashboard(),
    ),
    GoRoute(
      path: '/patient',
      builder: (context, state) => const PatientHome(),
    ),
    GoRoute(
      path: '/diet-agent',
      builder: (context, state) => const DietAgentScreen(),
    ),
    GoRoute(
      path: '/fitness-agent',
      builder: (context, state) => const FitnessAgentScreen(),
    ),
  ],
);

class AarogyanApp extends StatelessWidget {
  const AarogyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Aarogyan',
          theme: themeProvider.theme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
