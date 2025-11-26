import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:aarogyan/services/localization_service.dart';
import 'package:aarogyan/services/user_service.dart';
import 'package:aarogyan/services/session_service.dart';

class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _medicalConditionsController;
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = context.read<LanguageProvider>().languageCode;
    final userId = SessionService.getCurrentUserId();
    final user = userId != null ? UserService.getUserById(userId) : null;

    _ageController = TextEditingController(
      text: user?['demographics']?['age']?.toString() ?? '',
    );
    _genderController = TextEditingController(
      text: user?['demographics']?['gender'] ?? '',
    );
    _medicalConditionsController = TextEditingController(
      text: user?['medical']?['conditions']?.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final userId = SessionService.getCurrentUserId();
    if (userId == null) return;

    final user = UserService.getUserById(userId);
    if (user == null) return;

    user['demographics'] = {
      'age': int.tryParse(_ageController.text) ?? 0,
      'gender': _genderController.text,
    };
    user['medical'] = {
      'conditions': _medicalConditionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    };

    // Save to Hive via the users box
    final usersBox = Hive.box<Map>('users');
    await usersBox.put(userId, user);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('save', _selectedLanguage)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings', lang)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Section
            Text(
              AppStrings.get('language', lang),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Consumer<LanguageProvider>(
              builder: (context, langProvider, _) {
                return DropdownButton<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  items: langProvider.availableLanguages
                      .map(
                        (code) => DropdownMenuItem(
                          value: code,
                          child: Text(langProvider.languageNames[code]!),
                        ),
                      )
                      .toList(),
                  onChanged: (code) {
                    if (code != null) {
                      setState(() => _selectedLanguage = code);
                      langProvider.setLanguage(code);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 32),

            // Demographics Section
            Text(
              AppStrings.get('demographics', lang),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.get('age', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _genderController,
              decoration: InputDecoration(
                labelText: AppStrings.get('gender', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Medical Conditions Section
            Text(
              AppStrings.get('medicalConditions', lang),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _medicalConditionsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.get('healthIssues', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Diabetes, Hypertension, Asthma...',
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: Text(AppStrings.get('save', lang)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
