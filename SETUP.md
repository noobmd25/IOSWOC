# WOC (Who's On Call) - Setup Guide

## Overview
WOC is a hospital on-call scheduling and provider directory app built with SwiftUI and Supabase. This guide covers the complete setup process.

---

## Prerequisites

- **Xcode 15+** installed on macOS
- **iOS 16+** target device or simulator
- **Supabase account** (free tier available at https://app.supabase.com)

---

## Project Structure

```
WhosOnCall/
├── WhosOnCallApp.swift          # Main entry point (@main)
├── Views/
│   ├── ContentView.swift        # Universal container with environment objects
│   ├── RootView.swift           # Switches between LoginView and MainTabView
│   ├── LoginView.swift          # Email/password authentication
│   ├── MainTabView.swift        # Tab container for authenticated users
│   ├── ScheduleListView.swift   # On-call schedules list
│   ├── DirectoryListView.swift  # Provider directory with tap-to-call
│   └── SettingsView.swift       # User settings and sign out
├── ViewModels/
│   ├── AuthViewModel.swift      # Authentication logic
│   ├── ScheduleViewModel.swift  # Schedule data management
│   └── DirectoryViewModel.swift # Directory data management
├── Services/
│   ├── SupabaseClientProvider.swift # Supabase client singleton
│   ├── DataService.swift        # Data fetching with safe builder pattern
│   └── SessionController.swift  # Session management with auth events
└── Models/
    ├── Schedule.swift           # Schedule data model
    └── DirectoryEntry.swift     # Directory entry data model
```

---

## Supabase Setup

### 1. Create a Supabase Project

1. Go to https://app.supabase.com
2. Click "New Project"
3. Fill in:
   - Project name: `woc-hospital-app` (or your preferred name)
   - Database password: (create a strong password)
   - Region: (choose closest to your location)
4. Click "Create new project"
5. Wait for the project to finish setting up (1-2 minutes)

### 2. Get Your Project Credentials

1. In your Supabase project dashboard, click on "Settings" (gear icon)
2. Navigate to "API" section
3. Copy the following values:
   - **Project URL**: Found under "Project URL"
   - **Anon/Public Key**: Found under "Project API keys" → "anon" "public"

### 3. Configure the App

1. Open `/WhosOnCall/Services/SupabaseClientProvider.swift`
2. Replace the placeholder values:
   ```swift
   private let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
   private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
   ```
   
   With your actual credentials:
   ```swift
   private let supabaseURL = URL(string: "https://xxxxxxxxxxxxx.supabase.co")!
   private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
   ```

### 4. Create Database Tables

#### Create `schedules` table:

Run this SQL in Supabase SQL Editor (Database → SQL Editor → New Query):

```sql
-- Create schedules table
CREATE TABLE schedules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  specialty TEXT NOT NULL,
  provider TEXT NOT NULL,
  healthcare_plan TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;

-- Create policy to allow authenticated users to read schedules
CREATE POLICY "Allow authenticated users to read schedules"
  ON schedules FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_schedules_date ON schedules(date DESC);
CREATE INDEX idx_schedules_specialty ON schedules(specialty);
```

#### Create `directory` table:

```sql
-- Create directory table
CREATE TABLE directory (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  provider_name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE directory ENABLE ROW LEVEL SECURITY;

-- Create policy to allow authenticated users to read directory
CREATE POLICY "Allow authenticated users to read directory"
  ON directory FOR SELECT
  TO authenticated
  USING (true);

-- Create index for better query performance
CREATE INDEX idx_directory_provider_name ON directory(provider_name);
CREATE INDEX idx_directory_specialty ON directory(specialty);
```

### 5. Add Sample Data (Optional)

#### Sample Schedules:

```sql
INSERT INTO schedules (date, specialty, provider, healthcare_plan) VALUES
  ('2025-01-15', 'Cardiology', 'Dr. Sarah Johnson', 'HMO'),
  ('2025-01-15', 'Emergency Medicine', 'Dr. Michael Chen', 'PPO'),
  ('2025-01-16', 'Surgery', 'Dr. Emily Rodriguez', 'HMO'),
  ('2025-01-16', 'Cardiology', 'Dr. James Wilson', 'PPO'),
  ('2025-01-17', 'Emergency Medicine', 'Dr. Lisa Brown', 'HMO');
```

#### Sample Directory Entries:

```sql
INSERT INTO directory (provider_name, specialty, phone_number) VALUES
  ('Dr. Sarah Johnson', 'Cardiology', '(555) 123-4567'),
  ('Dr. Michael Chen', 'Emergency Medicine', '(555) 234-5678'),
  ('Dr. Emily Rodriguez', 'Surgery', '(555) 345-6789'),
  ('Dr. James Wilson', 'Cardiology', '(555) 456-7890'),
  ('Dr. Lisa Brown', 'Emergency Medicine', '(555) 567-8901');
```

### 6. Enable Email Authentication

1. In Supabase dashboard, go to "Authentication" → "Providers"
2. Make sure "Email" provider is enabled (it should be by default)
3. For testing, go to "Authentication" → "Users"
4. Click "Add user" → "Create new user"
5. Enter:
   - Email: `test@example.com` (or your test email)
   - Password: Create a password (remember this for login)
6. Click "Create user"

---

## Building and Running

### 1. Open the Project

1. Double-click `WhosOnCall.xcodeproj` to open in Xcode
2. Wait for Swift Package Manager to resolve dependencies (Supabase SDK)
   - This may take 1-2 minutes on first open
   - Watch the status bar in Xcode for "Resolving Packages..."

### 2. Select Target Device

1. In Xcode toolbar, click on the device selector (next to the Run button)
2. Select "iPhone 15" simulator (or any iOS 16+ simulator)

### 3. Build the Project

1. Press `Cmd + B` or go to Product → Build
2. Wait for the build to complete
3. Fix any build errors if they occur (check Supabase credentials are correctly set)

### 4. Run the App

1. Press `Cmd + R` or click the Play button
2. The simulator will launch
3. The app will install and open

### 5. Test the App

1. **Login**:
   - Enter the test email and password you created in Supabase
   - Tap "Sign In"
   - If successful, you'll see the main tab interface

2. **Schedules Tab**:
   - View on-call schedules
   - Use the search bar to filter by provider name
   - Tap the filter button (three lines) to filter by specialty or healthcare plan
   - Pull down to refresh

3. **Directory Tab**:
   - View provider directory
   - Search by provider name or specialty
   - Tap the phone button to initiate a call (only works on physical device)

4. **Settings Tab**:
   - View account info
   - Sign out

---

## Architecture

### MVVM Pattern
- **Models**: Plain Swift structs conforming to `Codable` and `Identifiable`
- **Views**: SwiftUI views with minimal logic
- **ViewModels**: `@MainActor` classes with `@Published` properties
- **Services**: Business logic and API communication

### Key Features Implemented

✅ **Authentication**
- Email/password login via Supabase Auth
- Session management with auth state listeners
- Automatic UI updates on auth state changes

✅ **Data Sync**
- Real-time data from Supabase PostgREST
- Safe query builder pattern with filters
- Error handling and loading states

✅ **Search & Filters**
- Debounced search (300ms) using Combine
- Specialty and healthcare plan filters
- Case-insensitive search

✅ **UI Features**
- Pull-to-refresh
- Searchable modifier
- NavigationStack
- Light/dark mode support
- Tab navigation

✅ **Provider Directory**
- Tap-to-call with `tel://` URL scheme
- Search by name or specialty
- Clean, accessible interface

---

## Troubleshooting

### Build Errors

**"Cannot find 'Supabase' in scope"**
- Make sure Package.swift dependencies are resolved
- Try: Product → Clean Build Folder (Cmd + Shift + K)
- Then rebuild (Cmd + B)

**"No such module 'Supabase'"**
- Delete `.build` folder and `Package.resolved`
- Restart Xcode
- Let SPM re-download dependencies

### Runtime Errors

**"Failed to load schedules/directory"**
- Check your Supabase URL and key in `SupabaseClientProvider.swift`
- Verify tables exist in Supabase (Database → Tables)
- Check RLS policies are set correctly

**"Sign in failed"**
- Verify user exists in Supabase (Authentication → Users)
- Check email and password are correct
- Ensure email provider is enabled in Supabase

**"No data showing"**
- Make sure you've added sample data to tables
- Check RLS policies allow authenticated reads
- Verify you're signed in successfully

### Simulator Limitations

- **Phone calls**: The `tel://` link will not work in simulator
  - Test on a physical iOS device to make actual calls
- **Push notifications**: Not implemented in this version

---

## Next Steps

### Recommended Enhancements

1. **Add Create/Edit functionality**
   - Allow adding new schedules
   - Edit existing entries
   - Update RLS policies to allow inserts/updates

2. **Implement Real-time Subscriptions**
   - Listen for database changes
   - Auto-update UI when data changes
   - Use Supabase Realtime

3. **Add Push Notifications**
   - Notify when on-call schedule changes
   - Reminder notifications

4. **Enhanced Filtering**
   - Date range picker for schedules
   - Multiple specialty selection
   - Saved filter presets

5. **Offline Support**
   - Cache data locally
   - Sync when online

6. **User Profiles**
   - Store user preferences
   - Customizable notifications
   - Favorite providers

---

## App Store Deployment

When ready to deploy:

1. **Update Bundle Identifier**
   - In Xcode, select project → General
   - Change Bundle Identifier to your unique ID

2. **Add App Icons**
   - Create app icons (1024x1024 required)
   - Add to Assets.xcassets

3. **Update Info.plist**
   - Add privacy descriptions for phone access

4. **Configure Signing**
   - Select your team in Signing & Capabilities
   - Use automatic signing

5. **Archive and Upload**
   - Product → Archive
   - Follow Xcode organizer prompts

---

## Support

For issues or questions:
- **Supabase Docs**: https://supabase.com/docs
- **SwiftUI Docs**: https://developer.apple.com/documentation/swiftui

---

## License

This project is provided as-is for hospital on-call scheduling purposes.
