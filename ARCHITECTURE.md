# WOC Architecture Documentation

## Application Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     WhosOnCallApp.swift                      │
│                      (@main Entry Point)                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      ContentView.swift                       │
│              (Injects SessionController as                   │
│                   @EnvironmentObject)                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       RootView.swift                         │
│              (Conditional Routing Based on                   │
│                  SessionController.isAuthenticated)          │
└──────────────────┬──────────────────────┬───────────────────┘
                   │                      │
        NOT AUTHENTICATED          AUTHENTICATED
                   │                      │
                   ▼                      ▼
        ┌──────────────────┐   ┌──────────────────────┐
        │  LoginView.swift │   │  MainTabView.swift   │
        └──────────────────┘   └──────────────────────┘
                   │                      │
                   │                      ├─── Tab 1: ScheduleListView
                   │                      ├─── Tab 2: DirectoryListView
                   │                      └─── Tab 3: SettingsView
                   │
                   ▼
        ┌──────────────────────┐
        │  AuthViewModel       │
        │  - signIn()          │
        │  - signUp()          │
        └──────────────────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │  SupabaseClientProvider      │
        │  client.auth.signIn()        │
        └──────────────────────────────┘
```

## MVVM Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                           VIEWS                              │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │   Schedule   │ │  Directory   │ │   Settings   │        │
│  │   ListView   │ │   ListView   │ │     View     │        │
│  └──────────────┘ └──────────────┘ └──────────────┘        │
│         │                │                 │                 │
│         └────────┬───────┴────────┬────────┘                │
└──────────────────┼────────────────┼─────────────────────────┘
                   │                │
                   ▼                ▼
┌─────────────────────────────────────────────────────────────┐
│                        VIEW MODELS                           │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │  Schedule    │ │  Directory   │ │    Auth      │        │
│  │  ViewModel   │ │  ViewModel   │ │  ViewModel   │        │
│  │              │ │              │ │              │        │
│  │ @Published   │ │ @Published   │ │ @Published   │        │
│  │ schedules    │ │ entries      │ │ email        │        │
│  │ searchText   │ │ searchText   │ │ password     │        │
│  │ filters      │ │              │ │ isLoading    │        │
│  └──────────────┘ └──────────────┘ └──────────────┘        │
│         │                │                 │                 │
│         └────────┬───────┴────────┬────────┘                │
└──────────────────┼────────────────┼─────────────────────────┘
                   │                │
                   ▼                ▼
┌─────────────────────────────────────────────────────────────┐
│                         SERVICES                             │
│  ┌────────────────────────────────────────────────┐         │
│  │              DataService                        │         │
│  │  - schedules(filters) -> [Schedule]            │         │
│  │  - directory(search) -> [DirectoryEntry]       │         │
│  └────────────────────────────────────────────────┘         │
│                                                               │
│  ┌────────────────────────────────────────────────┐         │
│  │         SessionController                       │         │
│  │  @Published isAuthenticated                     │         │
│  │  @Published currentUser                         │         │
│  │  - signOut()                                    │         │
│  └────────────────────────────────────────────────┘         │
│                                                               │
│  ┌────────────────────────────────────────────────┐         │
│  │      SupabaseClientProvider (Singleton)         │         │
│  │  - client: SupabaseClient                       │         │
│  │    - auth (Authentication)                      │         │
│  │    - database (PostgREST)                       │         │
│  └────────────────────────────────────────────────┘         │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                       SUPABASE CLOUD                         │
│  ┌──────────────┐              ┌──────────────┐            │
│  │ Auth Service │              │  PostgreSQL  │            │
│  │ - Sessions   │              │  - schedules │            │
│  │ - Users      │              │  - directory │            │
│  └──────────────┘              └──────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow: Schedule List

```
User Types in Search Box
         │
         ▼
ScheduleListView: searchText = "Dr. Smith"
         │
         ▼
ScheduleViewModel.$searchText (Combine Publisher)
         │
         ▼
.debounce(500ms) - Waits for user to stop typing
         │
         ▼
Task { await loadSchedules() }
         │
         ▼
DataService.schedules(searchText: "Dr. Smith", ...)
         │
         ▼
SupabaseClient.database.from("schedules")
    .ilike("provider", "%Dr. Smith%")
    .select()
    .execute()
         │
         ▼
HTTP Request to Supabase API
         │
         ▼
Supabase Server Processes Query
         │
         ▼
Returns JSON Response
         │
         ▼
Swift Decoder: JSON -> [Schedule]
         │
         ▼
ViewModel.schedules = results
         │
         ▼
@Published triggers SwiftUI update
         │
         ▼
ScheduleListView re-renders with new data
         │
         ▼
User sees filtered results
```

## Authentication Flow

```
User Opens App
      │
      ▼
WhosOnCallApp loads ContentView
      │
      ▼
ContentView creates SessionController
      │
      ▼
SessionController.init()
      │
      ├─── setupAuthListener()
      │    Listen to auth.authStateChanges
      │
      └─── checkInitialSession()
           Try to restore existing session
      │
      ▼
SessionController.isAuthenticated = false (initially)
      │
      ▼
RootView shows LoginView
      │
      ▼
User enters email/password and taps "Sign In"
      │
      ▼
AuthViewModel.signIn()
      │
      ▼
SupabaseClient.auth.signIn(email, password)
      │
      ▼
Supabase validates credentials
      │
      ▼
Returns Session object
      │
      ▼
SessionController hears authStateChanges event
      │
      ▼
SessionController.isAuthenticated = true
SessionController.currentUser = session.user
      │
      ▼
@Published triggers SwiftUI update
      │
      ▼
RootView switches to MainTabView
      │
      ▼
User sees app content
```

## Dependency Graph

```
WhosOnCallApp
    └── ContentView
            └── SessionController (Environment Object)
                    └── RootView
                            ├── LoginView (if not authenticated)
                            │       └── AuthViewModel
                            │               └── SupabaseClientProvider.client
                            │
                            └── MainTabView (if authenticated)
                                    ├── ScheduleListView
                                    │       └── ScheduleViewModel
                                    │               └── DataService
                                    │                       └── SupabaseClientProvider.client
                                    │
                                    ├── DirectoryListView
                                    │       └── DirectoryViewModel
                                    │               └── DataService
                                    │                       └── SupabaseClientProvider.client
                                    │
                                    └── SettingsView
                                            └── SessionController (from Environment)
```

## Key Design Patterns

### 1. Singleton Pattern
```swift
class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()
    private init() { ... }
}
```
**Why:** Ensures single Supabase client instance across the app.

### 2. Observer Pattern (@Published)
```swift
class ScheduleViewModel: ObservableObject {
    @Published var schedules: [Schedule] = []
}
```
**Why:** SwiftUI automatically re-renders when @Published properties change.

### 3. Dependency Injection (Environment Objects)
```swift
.environmentObject(sessionController)
```
**Why:** Makes SessionController accessible to all child views without prop drilling.

### 4. Repository Pattern (DataService)
```swift
class DataService {
    func schedules(...) async throws -> [Schedule]
    func directory(...) async throws -> [DirectoryEntry]
}
```
**Why:** Abstracts data access logic from ViewModels.

### 5. Debouncing (Combine)
```swift
$searchText
    .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
    .sink { ... }
```
**Why:** Reduces API calls by waiting for user to finish typing.

## Database Schema

```sql
┌─────────────────────────────────────┐
│           schedules                  │
├─────────────────────────────────────┤
│ id              UUID    PK           │
│ date            TIMESTAMPTZ          │
│ specialty       TEXT                 │
│ provider        TEXT                 │
│ healthcare_plan TEXT                 │
│ created_at      TIMESTAMPTZ          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│           directory                  │
├─────────────────────────────────────┤
│ id              UUID    PK           │
│ provider_name   TEXT                 │
│ specialty       TEXT                 │
│ phone_number    TEXT                 │
│ created_at      TIMESTAMPTZ          │
└─────────────────────────────────────┘
```

## Security Model (Row Level Security)

```
User Authenticates
      │
      ▼
Supabase issues JWT token
      │
      ▼
App includes JWT in all API requests
      │
      ▼
Supabase validates JWT
      │
      ▼
PostgreSQL evaluates RLS policies
      │
      ├─── POLICY: "Users can read schedules"
      │    ON schedules FOR SELECT
      │    TO authenticated
      │    USING (true)  ← Allows all authenticated users
      │
      └─── POLICY: "Users can read directory"
           ON directory FOR SELECT
           TO authenticated
           USING (true)
      │
      ▼
Query executes with filtered results
```

## State Management

```
┌───────────────────────────────────────────────────────┐
│              Application State                         │
├───────────────────────────────────────────────────────┤
│                                                        │
│  SessionController (@MainActor)                        │
│  ├─ isAuthenticated: Bool                             │
│  └─ currentUser: User?                                │
│                                                        │
│  ScheduleViewModel (@MainActor)                        │
│  ├─ schedules: [Schedule]                             │
│  ├─ searchText: String                                │
│  ├─ selectedSpecialty: String?                        │
│  ├─ selectedHealthcarePlan: String?                   │
│  ├─ isLoading: Bool                                   │
│  └─ errorMessage: String?                             │
│                                                        │
│  DirectoryViewModel (@MainActor)                       │
│  ├─ entries: [DirectoryEntry]                         │
│  ├─ searchText: String                                │
│  ├─ isLoading: Bool                                   │
│  └─ errorMessage: String?                             │
│                                                        │
│  AuthViewModel (@MainActor)                            │
│  ├─ email: String                                     │
│  ├─ password: String                                  │
│  ├─ isLoading: Bool                                   │
│  └─ errorMessage: String?                             │
│                                                        │
└───────────────────────────────────────────────────────┘

All ViewModels marked @MainActor to ensure UI updates
happen on the main thread.
```

## Threading Model

```
Main Thread (UI)
    │
    ├─ SwiftUI Views render
    ├─ User interactions
    └─ @Published property changes trigger re-renders
        │
        └─ Task { } creates async context
                │
                ▼
            Background Thread
                │
                ├─ Network requests (Supabase)
                ├─ JSON decoding
                └─ Data processing
                    │
                    └─ Results published back to @Published
                            │
                            ▼
                        Main Thread (automatic)
                            │
                            └─ SwiftUI re-renders
```

## Error Handling Strategy

```swift
// ViewModel Level
do {
    schedules = try await dataService.schedules(...)
} catch {
    errorMessage = error.localizedDescription  // User-friendly message
}

// View Level
if let errorMessage = viewModel.errorMessage {
    Text(errorMessage)
        .foregroundColor(.red)
}
```

**Philosophy:** 
- Catch errors at ViewModel layer
- Convert to user-friendly strings
- Display in UI via @Published errorMessage
- Never crash the app on network errors

---

This architecture ensures:
✅ Clear separation of concerns  
✅ Testable components  
✅ Reactive UI updates  
✅ Type-safe data flow  
✅ Scalable structure  
