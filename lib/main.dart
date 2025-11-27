import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/theme_provider.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:aarogyan/screens/common/splash_screen.dart';
import 'package:aarogyan/screens/auth/login_screen.dart';
import 'package:aarogyan/screens/auth/signup_screen.dart';
import 'package:aarogyan/screens/doctor/doctor_dashboard.dart';
import 'package:aarogyan/screens/patient/patient_home.dart';
import 'package:aarogyan/screens/patient/diet_agent_screen.dart';
import 'package:aarogyan/screens/patient/fitness_agent_screen.dart';
import 'package:aarogyan/screens/patient/patient_settings_screen.dart'; // Import PatientSettingsScreen
import 'package:aarogyan/screens/patient/tabs/emotional_diary_tab.dart'; // Import EmotionalDiaryTab
import 'package:aarogyan/screens/patient/tabs/mood_tracker_tab.dart'; // Import MoodTrackerTab
import 'package:aarogyan/screens/patient/tabs/patient_document_analysis_tab.dart'; // Import PatientDocumentAnalysisTab
import 'package:aarogyan/screens/patient/tabs/patient_ai_assistant_tab.dart'; // Import PatientAiAssistantTab
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aarogyan/services/local_db.dart';
import 'package:aarogyan/services/session_service.dart'; // Import SessionService

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize local on-device DB
  await LocalDb.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
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
    GoRoute(
      path: '/patient-settings',
      builder: (context, state) => const PatientSettingsScreen(),
    ),
    GoRoute(
      path: '/emotional-diary',
      builder: (context, state) => const EmotionalDiaryTab(),
    ),
    GoRoute(
      path: '/mood-tracker',
      builder: (context, state) => const MoodTrackerTab(),
    ),
    GoRoute(
      path: '/document-analysis',
      builder: (context, state) => const PatientDocumentAnalysisTab(),
    ),
    GoRoute(
      path: '/ai-assistant',
      builder: (context, state) => const PatientAiAssistantTab(),
    ),
  ],
);

class AarogyanApp extends StatefulWidget {
  const AarogyanApp({super.key});

  @override
  State<AarogyanApp> createState() => _AarogyanAppState();
}

class _AarogyanAppState extends State<AarogyanApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      SessionService.clear(); // Clear session when app is closed
    }
  }

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
