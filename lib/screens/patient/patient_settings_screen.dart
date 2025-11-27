import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:aarogyan/services/localization_service.dart';
import 'package:aarogyan/services/user_service.dart';
import 'package:aarogyan/services/session_service.dart';
import 'dart:convert';

class PatientSettingsScreen extends StatefulWidget {
  const PatientSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PatientSettingsScreen> createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen> {
  late String _userId;
  late Map<String, dynamic> _user;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _newEmailController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _conditionsController;
  late TextEditingController _surgeriesController;
  late TextEditingController _allergiesController;
  late String _selectedLanguage;
  String? _profilePhotoBase64;
  bool _showPasswordField = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userId = SessionService.getCurrentUserId() ?? '';
    _user = UserService.getUserById(_userId) ?? {};
    // Use default language 'en' if provider is not available
    _selectedLanguage = 'en';
    try {
      _selectedLanguage = context.read<LanguageProvider>().languageCode;
    } catch (_) {
      _selectedLanguage = 'en';
    }
    _initializeControllers();
  }

  void _initializeControllers() {
    _emailController = TextEditingController(text: _user['email'] ?? '');
    _passwordController = TextEditingController();
    _newEmailController = TextEditingController();

    _ageController = TextEditingController(
        text: _user['demographics']?['age']?.toString() ?? '');
    _genderController =
        TextEditingController(text: _user['demographics']?['gender'] ?? '');
    _heightController = TextEditingController(
        text: _user['demographics']?['height']?.toString() ?? '');
    _weightController = TextEditingController(
        text: _user['demographics']?['weight']?.toString() ?? '');

    _conditionsController = TextEditingController(
      text:
          (_user['medical']?['conditions'] as List<dynamic>?)?.join(', ') ?? '',
    );
    _surgeriesController = TextEditingController(
      text:
          (_user['medical']?['surgeries'] as List<dynamic>?)?.join(', ') ?? '',
    );
    _allergiesController = TextEditingController(
      text:
          (_user['medical']?['allergies'] as List<dynamic>?)?.join(', ') ?? '',
    );

    _profilePhotoBase64 = _user['profilePhoto'] as String?;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newEmailController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _conditionsController.dispose();
    _surgeriesController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _profilePhotoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _profilePhotoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  Future<void> _changeEmail() async {
    if (_passwordController.text.isEmpty || _newEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final success = await UserService.changeEmail(
      _userId,
      _newEmailController.text,
      _passwordController.text,
    );

    if (mounted) {
      if (success) {
        _emailController.text = _newEmailController.text;
        _newEmailController.clear();
        _passwordController.clear();
        setState(() => _showPasswordField = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update email (invalid password)')),
        );
      }
    }
  }

  Future<void> _saveDemographics() async {
    try {
      await UserService.updateDemographics(
        _userId,
        age: int.tryParse(_ageController.text),
        gender: _genderController.text,
        height: double.tryParse(_heightController.text),
        weight: double.tryParse(_weightController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demographics saved')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveMedicalInfo() async {
    try {
      await UserService.updateMedicalInfo(
        _userId,
        conditions: _conditionsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        surgeries: _surgeriesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        allergies: _allergiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical information saved')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _saveProfilePhoto() async {
    try {
      await UserService.updateProfilePhoto(_userId, _profilePhotoBase64);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _selectedLanguage;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings', lang)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/patient');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            Center(
              child: Column(
                children: [
                  if (_profilePhotoBase64 != null &&
                      _profilePhotoBase64!.isNotEmpty)
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          MemoryImage(base64Decode(_profilePhotoBase64!)),
                    )
                  else
                    const CircleAvatar(
                      radius: 60,
                      child: Icon(Icons.person, size: 60),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _captureImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Capture'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveProfilePhoto,
                    child: const Text('Save Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Email Change Section
            Text(
              AppStrings.get('email', lang),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppStrings.get('currentEmail', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_showPasswordField) ...[
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppStrings.get('password', lang),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newEmailController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('newEmail', lang),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _changeEmail,
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _showPasswordField = false);
                        _passwordController.clear();
                        _newEmailController.clear();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton(
                onPressed: () => setState(() => _showPasswordField = true),
                child: const Text('Change Email'),
              ),
            ],
            const SizedBox(height: 32),

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
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.get('height', lang),
                hintText: 'e.g., 170.5 cm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.get('weight', lang),
                hintText: 'e.g., 65.2 kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveDemographics,
              child: const Text('Save Demographics'),
            ),
            const SizedBox(height: 32),

            // Medical Conditions Section
            Text(
              AppStrings.get('medicalInformation', lang),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _conditionsController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.get('medicalConditions', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Diabetes, Hypertension, Asthma...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _surgeriesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.get('surgeryInfo', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Appendectomy (2020), ACL Repair (2022)...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _allergiesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: AppStrings.get('allergies', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Penicillin, Peanuts, Dust...',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _saveMedicalInfo,
              child: const Text('Save Medical Info'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
