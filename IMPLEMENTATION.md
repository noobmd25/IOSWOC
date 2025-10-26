# WOC iOS App - Implementation Summary

## Overview

The WOC (Who's On Call) iOS application has been fully implemented as a viewer-only SwiftUI + Supabase client that mirrors the web application's logic and user experience. This document provides a comprehensive overview of the implementation.

## Architecture

### MVVM Pattern

The application follows the Model-View-ViewModel (MVVM) architectural pattern:

```
┌─────────────┐
│    Views    │ ← SwiftUI Views (UI Layer)
└─────┬───────┘
      │ Bindings (@Published, @ObservedObject)
      ↓
┌─────────────┐
│ ViewModels  │ ← Business Logic & State Management
└─────┬───────┘
      │ Async/await calls
      ↓
┌─────────────┐
│  Services   │ ← Data Layer (Supabase, Session)
└─────┬───────┘
      │
      ↓
┌─────────────┐
│   Models    │ ← Data Structures
└─────────────┘
```

## Project Structure

### Main Entry Point

**WhosOnCallApp.swift** (`@main`)
- Single entry point for the entire application
- Initializes `SessionController` as environment object
- Loads `ContentView`

**ContentView.swift**
- Environment setup container
- Checks initial session state
- Renders `RootView`

**RootView.swift**
- Auth routing logic
- Displays `LoginView` or `MainTabView` based on authentication state

### Models (5 files)

All models are `Codable`, `Identifiable`, and `Hashable` for SwiftUI compatibility:

1. **Schedule.swift**
   - Core scheduling entity
   - Links specialty, provider, and healthcare plan
   - Implements `uniqueKey` for defensive deduplication (date+specialty+plan)
   - Joined fields: `specialtyName`, `providerName`, `healthcarePlanName`, `providerColorHex`

2. **DirectoryEntry.swift**
   - Provider contact information
   - Supports `resident_phone` for specific specialties
   - Includes `colorHex` for consistent provider identity

3. **Specialty.swift**
   - Medical specialty reference data
   - Simple model with `id`, `name`, `slug`

4. **HealthCarePlan.swift**
   - Insurance/care plan reference data
   - Simple model with `id`, `name`, `slug`

5. **Profile.swift**
   - User profile with role-based access
   - Enums for `UserRole` (viewer/scheduler/admin) and `UserStatus` (active/inactive)

### Services (3 files)

1. **SupabaseClientProvider.swift**
   - Singleton pattern for Supabase client
   - Configuration point for URL and anon key
   - ⚠️ **ACTION REQUIRED**: Replace placeholder credentials

2. **SessionController.swift**
   - `@MainActor` singleton observing auth state
   - Publishes `isAuthenticated` and `currentUserId`
   - Listens to Supabase auth state changes
   - Provides `checkSession()` for initial auth check

3. **DataService.swift**
   - `@MainActor` service for data operations
   - Implements filtering with `ScheduleFilters` and `DirectoryFilters`
   - **Key Methods**:
     - `fetchSchedules(filters:)`: Joins schedules with related tables
     - `fetchDirectory(filters:)`: Fetches providers with specialty info
     - `fetchSpecialties()`: Lookup data for filters
     - `fetchHealthCarePlans()`: Lookup data for filters
   - **Client-side operations**:
     - Search filtering (case-insensitive substring)
     - Defensive deduplication by uniqueKey
   - **Response models**: Private structs for decoding joined Supabase queries

### ViewModels (3 files)

All ViewModels are `@MainActor` and `ObservableObject`:

1. **AuthViewModel.swift**
   - Manages authentication flow
   - `signIn(email:password:)`: Email/password authentication
   - `signOut()`: Signs out user
   - Publishes `isLoading` and `errorMessage`

2. **ScheduleViewModel.swift**
   - Manages schedule list state
   - **Published Properties**:
     - `schedules`: Current list
     - `searchQuery`: Debounced by 300ms via Combine
     - `selectedSpecialtyId`, `selectedHealthcarePlanId`: Filter state
     - `specialties`, `healthcarePlans`: Lookup data
   - **Realtime**: Subscribes to `schedules` table changes
   - **Methods**:
     - `loadInitialData()`: Loads all data on first load
     - `loadSchedules()`: Applies filters and fetches
     - `refresh()`: Pull-to-refresh handler

3. **DirectoryViewModel.swift**
   - Manages directory list state
   - **Published Properties**:
     - `entries`: Current provider list
     - `searchQuery`: Debounced by 300ms
   - **Realtime**: Subscribes to `directory` table changes
   - **Methods**:
     - `loadDirectory()`: Fetches and filters providers
     - `refresh()`: Pull-to-refresh handler

### Views (5 files)

1. **LoginView.swift**
   - Email and password text fields
   - Loading state with `ProgressView`
   - Error message display
   - Calls `AuthViewModel.signIn()`

2. **MainTabView.swift**
   - Three-tab interface:
     - On-Call (calendar icon)
     - Directory (person.text.rectangle icon)
     - Settings (gear icon)

3. **ScheduleListView.swift**
   - **Features**:
     - Searchable modifier (binds to `searchQuery`)
     - Filter menu (specialty + healthcare plan pickers)
     - Pull-to-refresh
     - Empty state with `ContentUnavailableView`
     - Loading state with `ProgressView`
   - **ScheduleRow**:
     - Date formatting
     - Provider color circle (12pt)
     - Provider name and specialty/plan info
     - Internal Medicine badge highlighting healthcare plan
     - Color resolution from hex or deterministic UUID-based color
   - **Color Extension**: Hex color parsing for SwiftUI

4. **DirectoryListView.swift**
   - **Features**:
     - Searchable modifier
     - Pull-to-refresh
     - Empty state
     - Loading state
   - **DirectoryRow**:
     - Provider color circle with initials (40pt)
     - Provider name and specialty
     - Phone buttons with `tel://` URL scheme
     - Resident phone logic for specific specialties (Internal Medicine, Emergency Medicine, Surgery)
   - **PhoneButton**:
     - Formatted phone display
     - Blue pill design
     - Opens phone app on tap

5. **SettingsView.swift**
   - Read-only user information
   - User ID display
   - App version and build number
   - Sign Out button (destructive style)

## Key Implementation Details

### Search Debouncing

Using Combine's `debounce` operator with 300ms delay:

```swift
$searchQuery
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .sink { [weak self] _ in
        Task {
            await self?.loadSchedules()
        }
    }
    .store(in: &cancellables)
```

### Realtime Subscriptions

Supabase Realtime V2 API usage:

```swift
realtimeChannel = client.realtimeV2.channel("schedules")

realtimeChannel?.onPostgresChange(
    event: .all,
    schema: "public",
    table: "schedules"
) { [weak self] _ in
    Task { @MainActor in
        await self?.loadSchedules()
    }
}

await realtimeChannel?.subscribe()
```

### Defensive Deduplication

Client-side deduplication based on business logic:

```swift
var seen = Set<String>()
schedules = schedules.filter { schedule in
    seen.insert(schedule.uniqueKey).inserted
}
```

Where `uniqueKey = "\(date)_\(specialtyId)_\(healthcarePlanId)"`

### Color Identity

Two-stage color resolution:

1. If `color_hex` exists, parse and use it
2. Otherwise, generate deterministic color from UUID hash:

```swift
let hash = uuid.hashValue
let hue = Double(abs(hash) % 360) / 360.0
return Color(hue: hue, saturation: 0.6, brightness: 0.8)
```

### Resident Phone Logic

Specialties that show resident phone numbers:

- Internal Medicine
- Emergency Medicine
- Surgery

When applicable, shows both resident line (primary) and direct line (alternate).

### Internal Medicine Healthcare Plan Emphasis

For schedules with specialty containing "Internal Medicine", the healthcare plan is displayed as a badge:

```swift
if schedule.specialtyName?.contains("Internal Medicine") == true {
    Text(planName)
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.2))
        .foregroundColor(.blue)
        .cornerRadius(8)
}
```

## Supabase Integration

### Query Structure

The app uses Supabase PostgREST to join related tables in a single query:

```swift
client.database
    .from("schedules")
    .select("""
        id,
        date,
        specialty_id,
        provider_id,
        healthcare_plan_id,
        created_at,
        updated_at,
        specialties:specialty_id(name),
        directory:provider_id(provider_name, color_hex),
        healthcare_plans:healthcare_plan_id(name)
    """)
```

### Filter Application

Server-side filters:

```swift
.eq("specialty_id", value: specialtyId.uuidString)
.eq("healthcare_plan_id", value: planId.uuidString)
```

Client-side filters (for joined fields):

```swift
schedules.filter { schedule in
    (schedule.providerName?.lowercased().contains(lowercasedQuery) ?? false) ||
    (schedule.specialtyName?.lowercased().contains(lowercasedQuery) ?? false) ||
    (schedule.healthcarePlanName?.lowercased().contains(lowercasedQuery) ?? false)
}
```

### Row Level Security (RLS)

The app respects RLS policies. All queries run as authenticated user. Errors from RLS denials are caught and displayed non-intrusively.

## Platform Requirements

- **iOS**: 16.0+
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **Dependencies**: supabase-swift (2.0.0+)

## Build Configuration

### Target Settings

- Bundle Identifier: `com.woc.app`
- Deployment Target: iOS 16.0
- Swift Version: 5.0
- Mach-O Type: Executable
- Code Sign Style: Automatic
- SwiftUI Previews: Enabled

### Info.plist

Key configurations:
- UIApplicationSceneManifest: SwiftUI lifecycle
- UISupportedInterfaceOrientations: Portrait + Landscape
- UILaunchScreen: Default launch screen

## Parity with Web App

The iOS app achieves parity with the web application in the following areas:

### Data Model ✓
- Same table structure and relationships
- Same joined queries and data normalization
- Same role-based access model

### Filtering & Search ✓
- 300ms debounce matching web behavior
- Case-insensitive substring search
- Specialty and healthcare plan filters with same defaults

### Realtime Updates ✓
- Live subscriptions on schedules and directory
- Immediate UI updates on data changes

### Business Rules ✓
- Atomic scheduling (one entry per day+specialty+plan)
- Defensive client-side deduplication
- Internal Medicine plan emphasis
- Resident phone logic for applicable specialties

### Visual Consistency ✓
- Color-coded providers (hex or deterministic)
- Same color identity across app
- Dark mode support

### User Experience ✓
- Pull-to-refresh
- Empty states
- Loading states
- Error handling
- Search and filter UX

## Testing Checklist

Before production deployment, verify:

- [ ] Authentication flow (sign in/sign out)
- [ ] Schedule list displays correctly
- [ ] Filters work (specialty, healthcare plan)
- [ ] Search works with debounce
- [ ] Pull-to-refresh updates data
- [ ] Directory list displays correctly
- [ ] Directory search works
- [ ] Phone numbers are tappable (test on device)
- [ ] Realtime updates appear (test with concurrent web edits)
- [ ] Color consistency across views
- [ ] Internal Medicine plan badges appear
- [ ] Resident phone logic for applicable specialties
- [ ] Dark mode appearance
- [ ] Error states (no network, RLS denial)
- [ ] Empty states
- [ ] Settings screen (user info, sign out)

## Deployment Steps

1. **Configure Supabase**:
   - Replace placeholder URL and anon key in `SupabaseClientProvider.swift`
   - Set up database schema (see SETUP_GUIDE.md)
   - Enable RLS policies
   - Enable realtime on tables
   - Create test users

2. **Build in Xcode**:
   - Open `WhosOnCall.xcodeproj`
   - Wait for package resolution
   - Select target device
   - Build and run (Cmd+R)

3. **Test**:
   - Sign in with test credentials
   - Verify all features work
   - Test realtime updates
   - Test on physical device

4. **Prepare for Distribution**:
   - Update bundle identifier
   - Configure signing certificates
   - Prepare app metadata
   - Take screenshots
   - Submit to TestFlight/App Store

## Known Limitations

1. **Viewer-Only**: No create/update/delete operations (by design)
2. **Phone Dialing**: Only works on physical iOS devices (not simulator)
3. **Network Required**: No offline mode (future enhancement)
4. **No Push Notifications**: Requires additional setup (future enhancement)

## Future Enhancements

Potential improvements:

- [ ] Offline mode with local caching
- [ ] Push notifications for schedule changes
- [ ] Calendar export (add to iOS Calendar)
- [ ] Provider profile details view
- [ ] Schedule history view
- [ ] Accessibility improvements (VoiceOver labels)
- [ ] Localization support
- [ ] iPad optimization (adaptive layouts)
- [ ] Widget support (Today view, Lock screen)
- [ ] Shortcuts app integration

## Troubleshooting

See SETUP_GUIDE.md for detailed troubleshooting steps.

Common issues:
- Package resolution failures → Reset Package Caches
- Auth errors → Verify Supabase credentials
- No data → Check RLS policies and sample data
- Realtime not working → Verify realtime is enabled

## Support

For issues or questions:
- GitHub Issues: https://github.com/noobmd25/IOSWOC/issues
- Supabase Docs: https://supabase.com/docs
- Swift Supabase SDK: https://github.com/supabase-community/supabase-swift

## Credits

- **Web App Reference**: https://github.com/noobmd25/woc2
- **Supabase**: https://supabase.com
- **SwiftUI**: Apple

## License

This project is provided as-is for healthcare on-call management purposes.

---

**Implementation Date**: October 2024  
**Version**: 1.0.0  
**Build**: 1  
**Platform**: iOS 16.0+  
**Framework**: SwiftUI + Combine  
**Backend**: Supabase
