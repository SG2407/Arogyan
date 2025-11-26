# Quick Start Guide - Testing New Features

## Prerequisites
✓ Flutter 3.1+ installed
✓ Android emulator or device connected
✓ `.env` file with GRK_API_KEY configured

## Build & Run

### 1. Get Dependencies
```bash
cd /Users/sahil/Documents/CM/Arogyan
flutter pub get
```

### 2. Run on Emulator
```bash
flutter run -t lib/main.dart
```

Expected output:
```
Running Gradle build...
Built build/app/outputs/flutter-apk/app-debug.apk (619 ms)
Installing and launching... (time varies)
I/flutter (XXXXX): ✓ Hive initialized
✓ App launches on emulator
```

---

## Test Sequence

### Test 1: User Registration & Localization
**Goal**: Verify user can register and change language

1. **Tap "Sign Up"** on splash screen
2. **Fill form**:
   - Name: "John Patient"
   - Email: "patient1@test.com"
   - Password: "password123"
   - Toggle OFF "I am a Doctor"
3. **Tap "Sign Up"** button
4. **Verify**: App navigates to patient home
5. **Check Language**:
   - Tap settings icon in home page (if added)
   - Or create a route: `/patient/settings`
   - Change language to Hindi (हिंदी) or Marathi (मराठी)
   - **Expected**: Text changes immediately (if localization wired to UI)

---

### Test 2: Home Page Tile Navigation
**Goal**: Verify tiles navigate correctly

1. **On home page**, scroll down to see all tiles
2. **Quick Access Tiles** (should navigate to tabs):
   - Tap "Emotional Diary" → Should switch to Diary tab
   - Tap "Mood Tracker" → Should switch to Mood tab
   - Tap "Documents" → Should switch to Documents tab
   - Tap "AI Assistant" → Should switch to Chat tab
3. **Health Agent Tiles** (should open full-screen agents):
   - Tap "Diet Agent" → Opens diet agent screen
   - Tap "Fitness Coach" → Opens fitness agent screen

---

### Test 3: Diet Agent Functionality
**Goal**: Test AI diet agent chat

1. **Tap "Diet Agent"** from home page
2. **Type in input field**:
   ```
   I'm vegetarian with diabetes. What should I eat for breakfast?
   ```
3. **Tap send** or press Enter
4. **Observe**:
   - User message appears right-aligned
   - Loading indicator shows "Thinking..." (3-5 seconds)
   - AI response appears left-aligned
   - Response is relevant to the query

5. **Continue conversation**:
   - Ask follow-up questions
   - Verify multiple exchanges work smoothly

6. **Test error handling**:
   - Disconnect WiFi temporarily
   - Try to send message
   - Should show error message gracefully

---

### Test 4: Fitness Agent Functionality
**Goal**: Test AI fitness agent chat

1. **Tap "Fitness Coach"** from home page (or use back button from diet agent)
2. **Type in input field**:
   ```
   I have knee pain. What exercises can I do safely?
   ```
3. **Tap send**
4. **Verify**:
   - Message appears on screen
   - AI responds with exercise recommendations
   - UI is responsive (no freezing)
   - Loading state transitions smoothly

5. **Test message history**:
   - Scroll up in chat
   - Verify previous messages are visible
   - Ask new questions
   - Check conversation maintains context

---

### Test 5: Settings & Persistence
**Goal**: Test demographics storage and language persistence

1. **Navigate to Settings screen** (create route if not in menu):
   - OR: Look for settings icon/menu in app
   - OR: Add route to go router test

2. **Fill Settings**:
   - Language: Select "हिंदी" (Hindi)
   - Age: "28"
   - Gender: "Male"
   - Medical Conditions: "Diabetes, Hypertension"
   - Tap "Save"

3. **Verify**:
   - SnackBar shows "Saved" (or translated version)
   - Return to home page
   - Language remains Hindi
   - Close and reopen app
   - **Expected**: Language still Hindi, settings persist

---

### Test 6: AI Context Integration (Optional)
**Goal**: Verify AI uses medical context (if implemented)

1. **Set medical conditions in settings**:
   - Add: "Diabetes"
   - Add: "Heart condition"
   - Save

2. **Ask Diet Agent**:
   ```
   What should I eat?
   ```
   **Expected**: Response acknowledges diabetes/heart conditions

3. **Ask Fitness Agent**:
   ```
   What exercises can I do?
   ```
   **Expected**: Response suggests heart-safe exercises

---

## Test Checkpoints

### UI & Navigation
- [ ] All tiles visible on home page
- [ ] Quick access tiles navigate to correct tabs
- [ ] Agent tiles open full-screen chat interfaces
- [ ] Back navigation works from agent screens
- [ ] Bottom navigation bar functional

### Chat Features
- [ ] Messages display correctly (user right, assistant left)
- [ ] Input field accepts text
- [ ] Send button triggers API call
- [ ] Loading indicator shows during response
- [ ] Multiple exchanges work in sequence
- [ ] Long responses format correctly

### Localization
- [ ] Language selector visible in settings
- [ ] Language change applies to visible text
- [ ] Settings persist on app restart
- [ ] All 3 languages (en, hi, mr) work

### Data Persistence
- [ ] User settings saved after clicking Save
- [ ] Demographics retained after close/reopen
- [ ] Chat history visible in agent screens
- [ ] Session maintained after navigation

### Error Handling
- [ ] Network errors show graceful message
- [ ] Invalid input handled
- [ ] Empty messages don't trigger API call
- [ ] App doesn't crash on errors

---

## Debugging

### Check Logs
```bash
flutter logs
```

### Common Issues

**Issue**: App crashes on Settings screen
- **Cause**: Hive box not open
- **Fix**: Verify `LocalDb.init()` called in main.dart

**Issue**: AI responses don't load
- **Cause**: API key missing or invalid
- **Fix**: Check `.env` file has valid GRK_API_KEY

**Issue**: Language changes don't apply
- **Cause**: UI not wired to LanguageProvider
- **Fix**: Wrap text widgets with Consumer<LanguageProvider>

**Issue**: Settings not saving
- **Cause**: Hive put() not awaited
- **Fix**: Add `await` before usersBox.put()

---

## Success Criteria

All tests pass if:
1. ✓ App builds and runs without crashes
2. ✓ All navigation works (tabs and routes)
3. ✓ AI agents respond to queries
4. ✓ Settings persist across app restart
5. ✓ Language changes reflect in UI
6. ✓ No blocking errors in logs

---

## Next Steps After Testing

If all tests pass:
1. [ ] Commit changes to git
2. [ ] Update README with new features
3. [ ] Document remaining work (TODOs)
4. [ ] Plan next feature sprint

If tests fail:
1. [ ] Check error logs (`flutter logs`)
2. [ ] Verify API key in `.env`
3. [ ] Check Hive box names match
4. [ ] Review console output for stack traces
