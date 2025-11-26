# New Features Documentation

## 1. Diet Agent Screen
**File**: `lib/screens/patient/diet_agent_screen.dart`

### Purpose
Provides personalized diet recommendations through AI chat interface.

### Key Features
- Chat-based interface for asking diet questions
- Real-time AI responses using Groq API
- Message history display (user messages right-aligned, assistant left-aligned)
- Loading indicator while waiting for AI response
- Input field with send button and keyboard support

### Usage
```dart
// Navigate from home page
context.go('/diet-agent')

// Or from StatefulWidget
final response = await AiService.getAiResponse(message, UserRole.patient);
```

### Message Format
```dart
{
  'role': 'user' | 'assistant',
  'content': 'message text',
  'timestamp': ISO8601 string
}
```

---

## 2. Fitness Agent Screen
**File**: `lib/screens/patient/fitness_agent_screen.dart`

### Purpose
Provides personalized exercise routines and fitness coaching through AI.

### Key Features
- Identical interface to Diet Agent (maintains consistency)
- Exercise recommendations based on user's health conditions
- Real-time AI responses
- Message history with timestamps
- Recovery from network errors with fallback message

### Usage
```dart
// Navigate from home page
context.go('/fitness-agent')

// Or inline navigation
onTap: () => context.go('/fitness-agent'),
```

---

## 3. Language Provider
**File**: `lib/providers/language_provider.dart`

### Purpose
Manages language selection state across the app with persistence.

### Features
- 3 supported languages: English (en), Hindi (hi), Marathi (mr)
- Auto-saves selection to Hive sessionBox
- Easy access via Consumer<LanguageProvider>
- Language names in each language (Marathi shows as "मराठी", etc.)

### Usage
```dart
// Get current language
final lang = context.read<LanguageProvider>().languageCode;

// Change language
context.read<LanguageProvider>().setLanguage('hi');

// In UI
Consumer<LanguageProvider>(
  builder: (context, langProvider, _) {
    return Text(langProvider.availableLanguages.toString());
  }
)
```

### Available Methods
- `setLanguage(String code)`: Set active language
- `availableLanguages`: List of ['en', 'hi', 'mr']
- `languageNames`: Map of code → display name in that language
- `languageCode`: Current language code (getter)

---

## 4. Localization Service
**File**: `lib/services/localization_service.dart`

### Purpose
Centralized string translations for the entire app.

### Features
- 50+ UI strings translated
- Fallback to English if key not found
- Simple key-based lookup

### Supported Keys
```
hello, appName, login, signup, email, password, fullName, iAmDoctor,
alreadyHaveAccount, dontHaveAccount, invalidCredentials, signUpSuccess,
emotionalDiary, recordYourFeelings, moodTracker, trackYourProgress,
documents, storeMedicalRecords, aiAssistant, getGuidance,
diet, getDietPlan, fitness, getFitnessExercises, settings, manageYourAccount,
language, selectLanguage, demographics, age, gender, medicalConditions,
healthIssues, save, cancel, howAreYouFeeling, yourNextAppointment,
generalCheckup, tomorrow, drSmith, dietAgent, dietDescription,
fitnessAgent, fitnessDescription, askDiet, askFitness, logout, profile,
help, typeYourMessage, searchPatient, patientID, medicalHistory,
consultationNotes, memoNote, recordNote
```

### Usage
```dart
final text = AppStrings.get('dietAgent', 'en');  // "Diet Assistant"
final text = AppStrings.get('dietAgent', 'hi');  // "आहार सहायक"
final text = AppStrings.get('dietAgent', 'mr');  // "आहार सहायक"
```

---

## 5. Patient Settings Screen
**File**: `lib/screens/patient/patient_settings_screen.dart`

### Purpose
Allow patients to manage their profile, demographics, and app preferences.

### Features
- **Language Selection**: Dropdown to choose from en, hi, mr
- **Demographics**: Input fields for age and gender
- **Medical Conditions**: Multi-line textarea for listing health issues
- **Persistent Storage**: All changes saved to Hive users box
- **Localization**: All labels translated based on selected language

### Form Fields
```
Language: Dropdown (en, hi, mr)
Age: TextField (number input)
Gender: TextField (text input)
Medical Conditions: TextField multiline (comma-separated list)
```

### Usage
```dart
// Access from menu/navigation
context.go('/patient/settings')

// Or push as route
Navigator.push(context, MaterialPageRoute(
  builder: (_) => const PatientSettingsScreen(),
))
```

### Data Persistence
Settings are stored in Hive users box:
```dart
user['demographics'] = {
  'age': 28,
  'gender': 'Male'
}

user['medical'] = {
  'conditions': ['Diabetes', 'Hypertension']
}
```

---

## 6. Updated Home Tab
**File**: `lib/screens/patient/tabs/patient_home_tab.dart`

### Purpose
Improved home screen with quick access tiles and agent shortcuts.

### Layout
```
┌─────────────────────────┐
│ Hello, John             │
│ How are you feeling...? │
├─────────────────────────┤
│ Quick Access (2x2 grid) │
├─────────────────────────┤
│ Health Agents (2x1 grid)│
├─────────────────────────┤
│ Your Next Appointment   │
└─────────────────────────┘
```

### Tiles
1. **Quick Access** (navigate to tabs):
   - Emotional Diary → Tab 1
   - Mood Tracker → Tab 2
   - Documents → Tab 3
   - AI Assistant → Tab 4

2. **Health Agents** (open full-screen agent):
   - Diet Agent → `/diet-agent` route
   - Fitness Coach → `/fitness-agent` route

### Implementation
```dart
// Callback to parent for tab navigation
PatientHomeTab(onTabSelected: (index) => setState(() => _selectedIndex = index))

// Direct route navigation for agents
context.go('/diet-agent')
```

---

## 7. Router Updates
**File**: `lib/main.dart`

### New Routes Added
```dart
GoRoute(path: '/diet-agent', builder: (_, __) => const DietAgentScreen()),
GoRoute(path: '/fitness-agent', builder: (_, __) => const FitnessAgentScreen()),
```

### Complete Route List
- `/` - Splash screen
- `/login` - Login screen
- `/signup` - Signup screen
- `/doctor` - Doctor dashboard
- `/patient` - Patient home (bottom nav)
- `/diet-agent` - Diet AI agent
- `/fitness-agent` - Fitness AI agent

---

## Integration Notes

### Dependencies Used
- `flutter_dotenv`: Load `.env` for API key
- `hive` + `hive_flutter`: Local data persistence
- `go_router`: Navigation management
- `provider`: State management
- `groq`: AI API (via http package)

### Hive Boxes Required
```dart
await Hive.openBox<Map>('users');          // User profiles
await Hive.openBox<dynamic>('chats');      // Chat histories
await Hive.openBox<dynamic>('session');    // Session info
```

### Environment Variables
```
GRK_API_KEY=<your-groq-api-key>
API_BASE_URL=https://api.groq.com/openai/v1/chat/completions
```

---

## Future Enhancements

### Diet Agent
- [ ] Save diet plan history
- [ ] Store favorite recipes
- [ ] Export meal plans as PDF
- [ ] Integration with nutrition database

### Fitness Agent
- [ ] Save workout history
- [ ] Track calories burned
- [ ] Video demonstrations of exercises
- [ ] Progress analytics

### Settings
- [ ] Add profile photo upload
- [ ] Emergency contact information
- [ ] Notification preferences
- [ ] Privacy settings

### General
- [ ] Offline mode for saved chats
- [ ] Voice input for queries
- [ ] Share recommendations with doctor
- [ ] Calendar integration for appointments
