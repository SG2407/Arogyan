# Quick Reference Card

## Imports You'll Need

### Localization
```dart
import 'package:aarogyan/services/localization_service.dart';
import 'package:aarogyan/providers/language_provider.dart';
import 'package:provider/provider.dart';
```

### Navigation
```dart
import 'package:go_router/go_router.dart';
```

### Database
```dart
import 'package:hive/hive.dart';
import 'package:aarogyan/services/local_db.dart';
```

### Services
```dart
import 'package:aarogyan/services/user_service.dart';
import 'package:aarogyan/services/session_service.dart';
import 'package:aarogyan/services/ai/ai_service.dart';
```

---

## Common Code Snippets

### Display Localized Text
```dart
final lang = context.read<LanguageProvider>().languageCode;
Text(AppStrings.get('dietAgent', lang))
```

### Change Language Programmatically
```dart
context.read<LanguageProvider>().setLanguage('hi');
```

### Get Current User ID
```dart
final userId = SessionService.getCurrentUserId();
```

### Get User Data
```dart
final user = UserService.getUserById(userId);
print(user['demographics']['age']);
print(user['medical']['conditions']);
```

### Save to Hive
```dart
final usersBox = Hive.box<Map>('users');
await usersBox.put(userId, userMap);
```

### Call AI Service
```dart
final response = await AiService.getAiResponse(
  "Your question here",
  UserRole.patient  // or UserRole.doctor
);
```

### Navigate to Agent
```dart
context.go('/diet-agent');      // go_router
context.go('/fitness-agent');

// Or push onto stack
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const DietAgentScreen(),
));
```

### Use Localization in Dropdown
```dart
Consumer<LanguageProvider>(
  builder: (context, langProvider, _) {
    return DropdownButton<String>(
      value: langProvider.languageCode,
      items: langProvider.availableLanguages
          .map((code) => DropdownMenuItem(
            value: code,
            child: Text(langProvider.languageNames[code]!),
          ))
          .toList(),
      onChanged: (code) {
        if (code != null) langProvider.setLanguage(code);
      },
    );
  }
)
```

### Show SnackBar
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(AppStrings.get('save', lang)),
    duration: const Duration(seconds: 2),
  ),
);
```

### Async with Mounted Check
```dart
final response = await someAsyncCall();
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

---

## Constants & Enum Values

### User Roles
```dart
enum UserRole { patient, doctor }

// Usage: UserRole.patient, UserRole.doctor
```

### Language Codes
```dart
'en'  // English
'hi'  // हिंदी (Hindi)
'mr'  // मराठी (Marathi)
```

### Route Paths
```dart
'/'               // Splash
'/login'          // Login screen
'/signup'         // Signup screen
'/patient'        // Patient dashboard
'/doctor'         // Doctor dashboard
'/diet-agent'     // Diet AI agent
'/fitness-agent'  // Fitness AI agent
```

### Hive Box Names
```dart
'users'    // User profiles
'chats'    // Chat messages
'docs'     // Documents
'notes'    // Notes
'session'  // Session data
```

### AI Model
```dart
Model: meta-llama/llama-4-scout-17b-16e-instruct
Endpoint: https://api.groq.com/openai/v1/chat/completions
```

---

## Common Patterns

### Pattern 1: Add New Localized String
```dart
// 1. Add to AppStrings.translations in localization_service.dart
'myNewKey': {
  'en': 'English text',
  'hi': 'हिंदी टेक्स्ट',
  'mr': 'मराठी टेक्स्ट'
}

// 2. Use in widget
final lang = context.read<LanguageProvider>().languageCode;
Text(AppStrings.get('myNewKey', lang))
```

### Pattern 2: Save User Data
```dart
// 1. Get current user
final userId = SessionService.getCurrentUserId();
final user = UserService.getUserById(userId);

// 2. Modify
user['demographics']['age'] = 30;
user['medical']['conditions'] = ['Diabetes'];

// 3. Save to Hive
final usersBox = Hive.box<Map>('users');
await usersBox.put(userId, user);
```

### Pattern 3: Create New AI Agent Screen
```dart
class NewAgentScreen extends StatefulWidget {
  const NewAgentScreen({Key? key}) : super(key: key);
  @override
  State<NewAgentScreen> createState() => _NewAgentScreenState();
}

class _NewAgentScreenState extends State<NewAgentScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  
  Future<void> _sendMessage() async {
    final message = _messageController.text;
    _messageController.clear();
    
    setState(() {
      _messages.add({'role': 'user', 'content': message});
    });
    
    try {
      final response = await AiService.getAiResponse(message, UserRole.patient);
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
      });
    } catch (e) {
      // Handle error
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agent Name')),
      body: Column(
        children: [
          Expanded(child: ListView(...)),
          // Input field
        ],
      ),
    );
  }
}
```

### Pattern 4: Localize Entire Widget
```dart
Consumer<LanguageProvider>(
  builder: (context, langProvider, _) {
    final lang = langProvider.languageCode;
    return Column(
      children: [
        Text(AppStrings.get('hello', lang)),
        Text(AppStrings.get('appName', lang)),
      ],
    );
  }
)
```

---

## Troubleshooting Quick Links

| Issue | Solution |
|-------|----------|
| "Box not found" error | Call `LocalDb.init()` in main before runApp |
| Localization not updating | Wrap with `Consumer<LanguageProvider>` |
| AI response timeout | Check internet, verify API key in .env |
| Settings not saving | Add `await` before `usersBox.put()` |
| Navigation error | Check route path matches GoRoute definition |
| Hive type error | Ensure box is declared as `<Map>` not `<dynamic>` |

---

## File Locations Reference

| Feature | File |
|---------|------|
| Localization strings | `lib/services/localization_service.dart` |
| Language state | `lib/providers/language_provider.dart` |
| Diet agent | `lib/screens/patient/diet_agent_screen.dart` |
| Fitness agent | `lib/screens/patient/fitness_agent_screen.dart` |
| Settings form | `lib/screens/patient/patient_settings_screen.dart` |
| Home tiles | `lib/screens/patient/tabs/patient_home_tab.dart` |
| Routing | `lib/main.dart` |
| AI service | `lib/services/ai/ai_service.dart` |
| User service | `lib/services/user_service.dart` |
| Session service | `lib/services/session_service.dart` |
| DB init | `lib/services/local_db.dart` |

---

## Testing Commands

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Run tests
flutter test

# Run app
flutter run -t lib/main.dart

# Clean build
flutter clean && flutter pub get

# Check dependencies
flutter pub deps

# Build APK
flutter build apk --release
```

---

## Environment Variables
```
.env file should contain:
GRK_API_KEY=<your-groq-api-key>
API_BASE_URL=https://api.groq.com/openai/v1/chat/completions
```

---

## UI Component Map

```
PatientHome (State)
├── AppBar: Title + Settings + Logout
├── Body: _pages[_selectedIndex]
│   ├── [0] PatientHomeTab
│   │   ├── Quick Access Tiles (2x2 grid)
│   │   ├── Health Agent Tiles (2x1 grid)
│   │   └── Appointment Card
│   ├── [1] EmotionalDiaryTab
│   ├── [2] MoodTrackerTab
│   ├── [3] DocumentTab
│   └── [4] AiAssistantTab
└── BottomNavigationBar: 5 destinations

DietAgentScreen / FitnessAgentScreen
├── AppBar: Title
├── Body: ListView of messages
└── Bottom: TextField + Send button

PatientSettingsScreen
├── AppBar: Settings
├── Body:
│   ├── Language Dropdown
│   ├── Demographics Section
│   │   ├── Age TextField
│   │   └── Gender TextField
│   ├── Medical Conditions Section
│   │   └── Conditions TextArea
│   └── Save Button
```

---

## Common Function Signatures

```dart
// Localization
String AppStrings.get(String key, String languageCode)

// Language provider
void LanguageProvider.setLanguage(String code)
List<String> LanguageProvider.availableLanguages
Map<String, String> LanguageProvider.languageNames
String LanguageProvider.languageCode

// User service
Future<String> UserService.registerUser({...})
Map? UserService.login({...})
Map? UserService.getUserById(String id)
List<Map> UserService.searchUserByEmail(String email)

// Session service
Future<void> SessionService.setCurrentUserId(String id)
String? SessionService.getCurrentUserId()
Future<void> SessionService.clear()

// AI service
Future<String> AiService.getAiResponse(String message, UserRole role)
```

---

## Design System Colors

Access via:
```dart
final colorScheme = Theme.of(context).colorScheme;
colorScheme.primary       // Main brand color
colorScheme.secondary     // Secondary accent
colorScheme.surface       // Backgrounds
colorScheme.onSurface     // Text on backgrounds
colorScheme.error         // Error states
```

---

## Performance Tips

1. **Use const constructors** where possible
2. **Wrap long lists** with RepaintBoundary
3. **Cache AI responses** in Hive
4. **Use Provider** for efficient rebuilds (not setState globally)
5. **Lazy load** Hive boxes on first use
6. **Debounce** API calls in search/input fields

---

## Security Notes

⚠️ **Current Implementation (Development)**
- Passwords stored in plain text (NOT for production)
- API key in .env (could be exposed in APK)

✓ **For Production**
- Hash passwords with bcrypt
- Store API key in secure backend
- Use token-based auth (JWT)
- Encrypt sensitive data at rest
- Use HTTPS for all API calls

---

Generated for: **Aarogyan Healthcare App**  
Version: **0.2.0** (Post-Localization, Agents, Settings)  
Last Updated: **Current Session**
