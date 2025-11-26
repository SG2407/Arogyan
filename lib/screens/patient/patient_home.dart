import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/theme_provider.dart';
import 'package:aarogyan/screens/patient/tabs/patient_home_tab.dart';
import 'package:aarogyan/screens/patient/tabs/emotional_diary_tab.dart';
import 'package:aarogyan/screens/patient/tabs/mood_tracker_tab.dart';
import 'package:aarogyan/screens/patient/tabs/patient_document_analysis_tab.dart';
import 'package:aarogyan/screens/patient/tabs/patient_ai_assistant_tab.dart';
import 'package:aarogyan/services/session_service.dart';
import 'package:aarogyan/services/user_service.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  _PatientHomeState createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  String _userName = 'Patient';

  @override
  void initState() {
    super.initState();
    _pages = [
      PatientHomeTab(onTabSelected: _onItemTapped),
      const EmotionalDiaryTab(),
      const MoodTrackerTab(),
      const PatientDocumentAnalysisTab(),
      const PatientAiAssistantTab(),
    ];
    _loadUserName();
  }

  void _loadUserName() {
    final userId = SessionService.getCurrentUserId();
    if (userId != null) {
      final user = UserService.getUserById(userId);
      if (user != null) {
        setState(() {
          _userName = user['name'] as String? ?? 'Patient';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $_userName'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () {
              final themeProvider = context.read<ThemeProvider>();
              themeProvider.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Diary',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood_outlined),
            selectedIcon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.document_scanner_outlined),
            selectedIcon: Icon(Icons.document_scanner),
            label: 'Documents',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}
