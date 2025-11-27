import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/theme_provider.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:aarogyan/services/localization_service.dart';
import 'package:aarogyan/screens/patient/tabs/patient_home_tab.dart';
import 'package:aarogyan/services/session_service.dart';
import 'package:aarogyan/services/user_service.dart';
import 'package:aarogyan/widgets/app_sidebar.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({Key? key}) : super(key: key);

  @override
  _PatientHomeState createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  String _userName = 'Patient';

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        final lang = langProvider.languageCode;
        return Scaffold(
          appBar: AppBar(
            title: Text('${AppStrings.get('welcomePrefix', lang)} $_userName'),
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
            ],
          ),
          drawer: const AppSidebar(),
          body: const PatientHomeTab(),
        );
      },
    );
  }
}
