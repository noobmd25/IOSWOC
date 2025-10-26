# Testing Guide for WOC (Who's On Call)

This guide explains how to test the WOC application after setup.

---

## Pre-Testing Checklist

Before testing, ensure you've completed:

- [ ] Supabase project created
- [ ] Database tables created (`schedules`, `directory`)
- [ ] Sample data inserted (optional but recommended)
- [ ] Test user created in Supabase Authentication
- [ ] Supabase credentials updated in `SupabaseClientProvider.swift`
- [ ] Xcode project opened and dependencies resolved
- [ ] Project builds successfully (⌘B)

---

## Manual Testing Scenarios

### 1. Authentication Testing

#### Login Flow
**Test Case**: Valid credentials
1. Launch the app
2. Enter valid email and password
3. Tap "Sign In"
4. **Expected**: Shows loading indicator, then navigates to MainTabView

**Test Case**: Invalid credentials
1. Launch the app
2. Enter incorrect email or password
3. Tap "Sign In"
4. **Expected**: Shows error message "Sign in failed: ..."

**Test Case**: Empty fields
1. Launch the app
2. Leave email or password empty
3. Tap "Sign In"
4. **Expected**: Shows error "Please enter both email and password"

#### Session Persistence
**Test Case**: Session restoration
1. Sign in successfully
2. Force quit the app (swipe up in app switcher)
3. Relaunch the app
4. **Expected**: Automatically shows MainTabView (session restored)

#### Sign Out
**Test Case**: Sign out flow
1. Navigate to Settings tab
2. Tap "Sign Out"
3. **Expected**: Shows loading, then returns to LoginView

---

### 2. Schedules View Testing

#### Initial Load
**Test Case**: Load schedules
1. Sign in
2. Navigate to Schedules tab (if not already there)
3. **Expected**: Shows list of schedules from database

**Test Case**: Empty state
1. Clear all schedules from Supabase database
2. Pull to refresh
3. **Expected**: Shows appropriate message (or empty list)

#### Search Functionality
**Test Case**: Search by provider name
1. Navigate to Schedules tab
2. Tap search bar
3. Type partial provider name (e.g., "Sarah")
4. Wait 300ms for debounce
5. **Expected**: Shows filtered results matching search

**Test Case**: Clear search
1. After searching, tap "Cancel" or clear text
2. **Expected**: Shows all schedules again

#### Filter by Specialty
**Test Case**: Specialty filter
1. Navigate to Schedules tab
2. Tap filter button (three lines icon)
3. Select "Specialty" → "Cardiology"
4. **Expected**: Shows only Cardiology schedules

**Test Case**: Clear specialty filter
1. After filtering, tap filter button
2. Select "Specialty" → "All"
3. **Expected**: Shows all schedules

#### Filter by Healthcare Plan
**Test Case**: Healthcare plan filter
1. Navigate to Schedules tab
2. Tap filter button
3. Select "Healthcare Plan" → "HMO"
4. **Expected**: Shows only HMO schedules

**Test Case**: Combined filters
1. Apply specialty filter: "Emergency Medicine"
2. Apply healthcare plan filter: "PPO"
3. **Expected**: Shows only Emergency Medicine + PPO schedules

#### Pull to Refresh
**Test Case**: Refresh schedules
1. Navigate to Schedules tab
2. Pull down on the list
3. Release
4. **Expected**: Shows loading indicator, reloads data from server

---

### 3. Directory View Testing

#### Initial Load
**Test Case**: Load directory
1. Sign in
2. Navigate to Directory tab
3. **Expected**: Shows list of providers alphabetically

#### Search Functionality
**Test Case**: Search by provider name
1. Navigate to Directory tab
2. Tap search bar
3. Type provider name (e.g., "Johnson")
4. Wait 300ms
5. **Expected**: Shows filtered results

**Test Case**: Search by specialty
1. Tap search bar
2. Type specialty (e.g., "Cardiology")
3. **Expected**: Shows all cardiologists

#### Tap to Call
**Test Case**: Phone number link (physical device only)
1. Navigate to Directory tab
2. Tap green phone button on any entry
3. **Expected**: iOS prompts "Call [phone number]?"
4. Tap "Cancel" to dismiss

**Note**: This feature only works on physical iOS devices, not simulators.

#### Pull to Refresh
**Test Case**: Refresh directory
1. Navigate to Directory tab
2. Pull down on the list
3. Release
4. **Expected**: Reloads directory from server

---

### 4. Settings View Testing

#### Account Information
**Test Case**: Display user info
1. Navigate to Settings tab
2. **Expected**: Shows current user's email address

#### App Information
**Test Case**: App metadata
1. Navigate to Settings tab
2. Scroll to "About" section
3. **Expected**: Shows version "1.0.0" and app name

---

### 5. UI/UX Testing

#### Dark Mode
**Test Case**: Theme switching
1. Open app in light mode
2. Enable dark mode in iOS Settings → Display & Brightness
3. Return to app
4. **Expected**: UI adapts to dark mode colors

**Test Case**: Switch back to light mode
1. Disable dark mode in iOS Settings
2. Return to app
3. **Expected**: UI adapts to light mode colors

#### Navigation
**Test Case**: Tab switching
1. Tap each tab (Schedules, Directory, Settings)
2. **Expected**: Smooth transition, correct content shown

#### Keyboard Handling
**Test Case**: Search field keyboard
1. Tap search bar in any list view
2. Type text
3. Tap return or outside search bar
4. **Expected**: Keyboard dismisses properly

---

### 6. Error Handling Testing

#### Network Errors
**Test Case**: No internet connection
1. Disable WiFi and cellular on device/simulator
2. Pull to refresh on any list
3. **Expected**: Shows error message about network failure

**Test Case**: Invalid Supabase credentials
1. Change Supabase URL to invalid value
2. Rebuild and run
3. Try to sign in
4. **Expected**: Shows error message

#### Authentication Errors
**Test Case**: Session expiration (advanced)
1. Sign in
2. Go to Supabase dashboard
3. Delete the user
4. Try to refresh data in app
5. **Expected**: Should handle gracefully and show login screen

---

### 7. Performance Testing

#### Search Debouncing
**Test Case**: Rapid typing
1. Navigate to Schedules or Directory
2. Type quickly in search bar
3. **Expected**: API calls only happen after 300ms pause in typing

#### List Scrolling
**Test Case**: Smooth scrolling
1. Navigate to list with many items (>20)
2. Scroll rapidly up and down
3. **Expected**: Smooth performance, no lag

---

## Automated Testing (Not Implemented)

The following are suggestions for future automated tests:

### Unit Tests
```swift
// Example tests to add:
- AuthViewModel: Test signIn() success/failure
- ScheduleViewModel: Test search debouncing
- DirectoryViewModel: Test filtering logic
- DataService: Test query building
- SessionController: Test auth state changes
```

### UI Tests
```swift
// Example UI tests to add:
- Test login flow
- Test tab navigation
- Test search functionality
- Test pull-to-refresh
- Test filters application
```

To add tests in Xcode:
1. File → New → Target
2. Choose "Unit Testing Bundle" or "UI Testing Bundle"
3. Write test cases using XCTest framework

---

## Test Data

### Sample Schedules for Testing
```sql
INSERT INTO schedules (date, specialty, provider, healthcare_plan) VALUES
  ('2025-01-15', 'Cardiology', 'Dr. Sarah Johnson', 'HMO'),
  ('2025-01-15', 'Emergency Medicine', 'Dr. Michael Chen', 'PPO'),
  ('2025-01-16', 'Surgery', 'Dr. Emily Rodriguez', 'HMO'),
  ('2025-01-16', 'Cardiology', 'Dr. James Wilson', 'PPO'),
  ('2025-01-17', 'Emergency Medicine', 'Dr. Lisa Brown', 'HMO'),
  ('2025-01-17', 'Surgery', 'Dr. Robert Taylor', 'PPO'),
  ('2025-01-18', 'Cardiology', 'Dr. Sarah Johnson', 'HMO'),
  ('2025-01-18', 'Emergency Medicine', 'Dr. Michael Chen', 'PPO');
```

### Sample Directory Entries
```sql
INSERT INTO directory (provider_name, specialty, phone_number) VALUES
  ('Dr. Sarah Johnson', 'Cardiology', '(555) 123-4567'),
  ('Dr. Michael Chen', 'Emergency Medicine', '(555) 234-5678'),
  ('Dr. Emily Rodriguez', 'Surgery', '(555) 345-6789'),
  ('Dr. James Wilson', 'Cardiology', '(555) 456-7890'),
  ('Dr. Lisa Brown', 'Emergency Medicine', '(555) 567-8901'),
  ('Dr. Robert Taylor', 'Surgery', '(555) 678-9012');
```

---

## Known Limitations

1. **Simulator Call Limitation**: `tel://` links don't work in iOS Simulator
   - **Workaround**: Test on physical device

2. **No Create/Edit**: Current version is read-only
   - Users cannot add/edit schedules or directory entries
   - Must be done via Supabase dashboard

3. **Limited Pagination**: Shows max 100 items per query
   - For production, implement pagination/infinite scroll

4. **No Offline Mode**: Requires internet connection
   - No cached data
   - Future: Implement local database sync

---

## Test Results Template

Use this template to document your test results:

```markdown
## Test Session: [Date]
**Tester**: [Name]
**Device**: [iPhone 15 Simulator / Physical Device]
**iOS Version**: [16.0]
**Build**: [1.0.0]

### Authentication
- [ ] Login with valid credentials: PASS/FAIL
- [ ] Login with invalid credentials: PASS/FAIL
- [ ] Sign out: PASS/FAIL

### Schedules
- [ ] Load schedules: PASS/FAIL
- [ ] Search schedules: PASS/FAIL
- [ ] Filter by specialty: PASS/FAIL
- [ ] Filter by healthcare plan: PASS/FAIL
- [ ] Pull to refresh: PASS/FAIL

### Directory
- [ ] Load directory: PASS/FAIL
- [ ] Search directory: PASS/FAIL
- [ ] Pull to refresh: PASS/FAIL

### Settings
- [ ] Display account info: PASS/FAIL
- [ ] Sign out: PASS/FAIL

### Notes:
[Any issues or observations]
```

---

## Troubleshooting Test Failures

### "No data showing"
1. Verify tables exist in Supabase
2. Check RLS policies are configured
3. Ensure sample data is inserted
4. Confirm user is authenticated

### "Search not working"
1. Check search query is correct
2. Verify debounce delay (wait 300ms)
3. Look for error messages in Xcode console

### "Sign in fails"
1. Verify Supabase credentials in code
2. Check user exists in Supabase Auth
3. Ensure email/password are correct
4. Check network connection

### "App crashes"
1. Check Xcode console for error messages
2. Verify all dependencies are resolved
3. Clean build folder (Cmd+Shift+K)
4. Rebuild (Cmd+B)

---

## Reporting Issues

When reporting issues, include:
1. iOS version
2. Device type (simulator/physical)
3. Steps to reproduce
4. Expected behavior
5. Actual behavior
6. Screenshots/screen recordings
7. Xcode console logs

---

## Success Criteria

The app is ready for deployment when:
- ✅ All authentication flows work
- ✅ Data loads from Supabase correctly
- ✅ Search and filters function properly
- ✅ UI is responsive and smooth
- ✅ Errors are handled gracefully
- ✅ Dark mode works correctly
- ✅ No crashes during normal use
- ✅ Session persistence works

---

**Happy Testing! 🚀**
