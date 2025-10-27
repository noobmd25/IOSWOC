# WOC (Who's On Call) - iOS App

A SwiftUI + Supabase viewer-only client for managing on-call schedules in healthcare settings.

## Overview

WOC streamlines on-call management for hospitals and ED teams. View real-time schedules, filter by specialty or healthcare plan, and access an updated provider directory with quick-dial links—all in a fast, secure SwiftUI app powered by Supabase.

## Features

- **On-Call Schedule Viewer**: Real-time schedules with filtering by specialty and healthcare plan
- **Provider Directory**: Contact information with quick-dial phone links
- **Real-time Updates**: Automatic synchronization with Supabase backend
- **Search & Filter**: Debounced search with 300ms delay, specialty and plan filters
- **Color-Coded Providers**: Consistent visual identity per provider
- **Dark Mode Support**: Full light/dark theme support
- **Viewer-Only Access**: Read-only client respecting RLS policies

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Supabase account

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/noobmd25/IOSWOC.git
cd IOSWOC
```

### 2. Configure Supabase

Edit `WhosOnCall/Services/SupabaseClientProvider.swift` and replace the placeholders:

```swift
private let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
```

### 3. Open in Xcode

```bash
open WhosOnCall.xcodeproj
```

### 4. Build and Run

- Select your target device or simulator
- Press `Cmd + R` to build and run

## Project Structure

```
WhosOnCall/
├── Main/
│   ├── WhosOnCallApp.swift       # App entry point
│   ├── ContentView.swift         # Environment setup
│   └── RootView.swift            # Auth routing
├── Views/
│   ├── LoginView.swift           # Authentication
│   ├── MainTabView.swift         # Tab navigation
│   ├── ScheduleListView.swift   # On-call schedules
│   ├── DirectoryListView.swift  # Provider directory
│   └── SettingsView.swift        # User settings
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── ScheduleViewModel.swift
│   └── DirectoryViewModel.swift
├── Services/
│   ├── SupabaseClientProvider.swift
│   ├── DataService.swift
│   └── SessionController.swift
├── Models/
│   ├── Schedule.swift
│   ├── DirectoryEntry.swift
│   ├── Specialty.swift
│   ├── HealthCarePlan.swift
│   └── Profile.swift
└── Resources/
    └── Info.plist
```

## Supabase Setup

### Database Schema

Create the following tables in your Supabase project:

#### 1. Specialties Table

```sql
CREATE TABLE specialties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 2. Healthcare Plans Table

```sql
CREATE TABLE healthcare_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 3. Directory Table (Providers)

```sql
CREATE TABLE directory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_name TEXT NOT NULL,
    specialty_id UUID REFERENCES specialties(id),
    phone_number TEXT NOT NULL,
    resident_phone TEXT,
    color_hex TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 4. Schedules Table

```sql
CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL,
    specialty_id UUID REFERENCES specialties(id),
    provider_id UUID REFERENCES directory(id),
    healthcare_plan_id UUID REFERENCES healthcare_plans(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 5. Profiles Table

```sql
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    role TEXT NOT NULL DEFAULT 'viewer' CHECK (role IN ('viewer', 'scheduler', 'admin')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Row Level Security (RLS)

Enable RLS on all tables:

```sql
ALTER TABLE specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE healthcare_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE directory ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

### RLS Policies

#### Read-only access for authenticated users:

```sql
-- Specialties
CREATE POLICY "Allow read access to authenticated users" ON specialties
    FOR SELECT TO authenticated USING (true);

-- Healthcare Plans
CREATE POLICY "Allow read access to authenticated users" ON healthcare_plans
    FOR SELECT TO authenticated USING (true);

-- Directory
CREATE POLICY "Allow read access to authenticated users" ON directory
    FOR SELECT TO authenticated USING (true);

-- Schedules
CREATE POLICY "Allow read access to authenticated users" ON schedules
    FOR SELECT TO authenticated USING (true);

-- Profiles
CREATE POLICY "Allow users to read their own profile" ON profiles
    FOR SELECT TO authenticated USING (auth.uid() = id);
```

### Realtime Configuration

Enable realtime for schedules and directory:

```sql
-- Enable realtime on schedules table
ALTER PUBLICATION supabase_realtime ADD TABLE schedules;

-- Enable realtime on directory table
ALTER PUBLICATION supabase_realtime ADD TABLE directory;
```

### Authentication Setup

1. In your Supabase dashboard, go to Authentication → Settings
2. Enable Email authentication
3. Configure your email templates as needed
4. Create test users via Authentication → Users

## Architecture

The app follows MVVM (Model-View-ViewModel) architecture:

- **Models**: Data structures matching Supabase schema
- **Services**: Supabase client, data fetching, session management
- **ViewModels**: Business logic, state management, Combine publishers
- **Views**: SwiftUI views with declarative UI

### Key Features

- **Search Debouncing**: 300ms debounce using Combine
- **Realtime Subscriptions**: Live updates from Supabase
- **Defensive Deduplication**: Client-side deduplication by date+specialty+plan
- **Color Identity**: Deterministic colors per provider (from hex or UUID hash)
- **Resident Phone Logic**: Show resident/alternate numbers for specific specialties
- **Filter Persistence**: Sticky filters for specialty and healthcare plan

## Usage

### Login

1. Launch the app
2. Enter your email and password
3. Tap "Sign In"

### On-Call Schedule

- View all scheduled providers
- Search by provider name, specialty, or plan
- Filter by specialty and healthcare plan using the filter button
- Pull to refresh for latest data
- Tap Internal Medicine entries to see emphasized healthcare plan

### Provider Directory

- Browse all providers
- Search by name or specialty
- Tap phone numbers to initiate calls
- View resident/alternate numbers for applicable specialties

### Settings

- View your user ID
- Sign out

## Dependencies

- [supabase-swift](https://github.com/supabase-community/supabase-swift) (v2.0.0+)

## Web App Reference

This iOS app mirrors the logic and UX of the web application:
- Repository: [https://github.com/noobmd25/woc2](https://github.com/noobmd25/woc2)

## License

This project is provided as-is for healthcare on-call management purposes.

## Support

For issues or questions, please open an issue on GitHub.
# IOSWOC
WOC (Who’s On Call) streamlines on-call management for hospitals and ED teams. View real-time schedules, filter by specialty or healthcare plan, and access an updated provider directory with quick-dial links—all in a fast, secure SwiftUI app powered by Supabase.
