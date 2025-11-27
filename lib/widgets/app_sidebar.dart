import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:aarogyan/services/localization_service.dart';
import 'package:aarogyan/services/session_service.dart';
import 'package:aarogyan/services/user_service.dart';
import 'dart:convert';

class AppSidebar extends StatefulWidget {
  final String title;

  const AppSidebar({
    Key? key,
    this.title = 'Menu',
  }) : super(key: key);

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  late String _userId;
  late Map<String, dynamic> _user;

  @override
  void initState() {
    super.initState();
    _userId = SessionService.getCurrentUserId() ?? '';
    _user = UserService.getUserById(_userId) ?? {};
  }

  Future<void> _logout() async {
    await SessionService.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, langProvider, _) {
        final lang = langProvider.languageCode;
        final profilePhoto = _user['profilePhoto'] as String?;
        final userName = _user['name'] ?? 'User';

        return Drawer(
          child: Column(
            children: [
              // Drawer Header with Profile
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (profilePhoto != null && profilePhoto.isNotEmpty)
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            MemoryImage(base64Decode(profilePhoto)),
                      )
                    else
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: Text(AppStrings.get('settings', lang)),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/patient-settings');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(AppStrings.get('about', lang)),
                      onTap: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${AppStrings.get('appName', lang)} v1.0 - Healthcare Assistant'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Logout Button at Bottom
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: Text(AppStrings.get('logout', lang)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
