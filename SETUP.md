# WOC (Who's On Call) - Hospital On-Call Scheduling App

A complete SwiftUI + Supabase application for managing hospital on-call scheduling and provider directory.

## Features

- 🔐 **Authentication**: Secure email/password authentication via Supabase
- 📅 **Schedule Management**: View and filter on-call schedules by specialty and healthcare plan
- 📖 **Provider Directory**: Searchable directory with quick-dial functionality
- 🔄 **Real-time Sync**: Live data synchronization with Supabase
- 🔍 **Smart Search**: Debounced search with Combine for optimal performance
- ↻ **Pull-to-Refresh**: Easy data refreshing on all lists
- 🌓 **Dark Mode**: Full light/dark mode support

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Supabase account

## Architecture

The app follows MVVM architecture with clear separation of concerns:

```
WhosOnCall/
├── Main/
│   ├── WhosOnCallApp.swift      # @main entry point
│   ├── ContentView.swift         # Universal container with environment objects
│   └── RootView.swift            # Auth-based routing
├── Views/
│   ├── LoginView.swift           # Authentication screen
│   ├── MainTabView.swift         # Main tab navigation
│   ├── ScheduleListView.swift    # Schedule list with filters
│   ├── DirectoryListView.swift   # Provider directory
│   └── SettingsView.swift        # Settings and sign out
├── ViewModels/
│   ├── AuthViewModel.swift       # Authentication logic
│   ├── ScheduleViewModel.swift   # Schedule data management
│   └── DirectoryViewModel.swift  # Directory data management
├── Services/
│   ├── SupabaseClientProvider.swift  # Supabase client singleton
│   ├── SessionController.swift       # Session state management
│   └── DataService.swift             # Data queries
└── Models/
    ├── Schedule.swift            # Schedule model
    └── DirectoryEntry.swift      # Directory entry model
```

## Setup Instructions

### 1. Supabase Setup

#### Create a Supabase Project
1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your project URL and anon key from Settings > API

#### Create Database Tables

Run the following SQL in your Supabase SQL Editor:

```sql
-- Create schedules table
CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    specialty TEXT NOT NULL,
    provider TEXT NOT NULL,
    healthcare_plan TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create directory table
CREATE TABLE directory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_name TEXT NOT NULL,
    specialty TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE directory ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Authenticated users can read schedules"
    ON schedules FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Authenticated users can read directory"
    ON directory FOR SELECT
    TO authenticated
    USING (true);

-- Optional: Create sample data
INSERT INTO schedules (date, specialty, provider, healthcare_plan) VALUES
    (NOW() + INTERVAL '1 day', 'Cardiology', 'Dr. Sarah Johnson', 'Medicare'),
    (NOW() + INTERVAL '2 days', 'Emergency Medicine', 'Dr. Michael Chen', 'Medicaid'),
    (NOW() + INTERVAL '3 days', 'Orthopedics', 'Dr. Emily Davis', 'Private'),
    (NOW() + INTERVAL '4 days', 'Neurology', 'Dr. James Wilson', 'Medicare');

INSERT INTO directory (provider_name, specialty, phone_number) VALUES
    ('Dr. Sarah Johnson', 'Cardiology', '(555) 123-4567'),
    ('Dr. Michael Chen', 'Emergency Medicine', '(555) 234-5678'),
    ('Dr. Emily Davis', 'Orthopedics', '(555) 345-6789'),
    ('Dr. James Wilson', 'Neurology', '(555) 456-7890');
```

### 2. Configure the App

1. Open `WhosOnCall/Services/SupabaseClientProvider.swift`
2. Replace the placeholder values with your Supabase credentials:

```swift
let supabaseURL = URL(string: "https://your-project.supabase.co")!
let supabaseKey = "your-anon-key-here"
```

### 3. Build and Run

#### Using Swift Package Manager (Command Line)

```bash
# Resolve dependencies
swift package resolve

# Build the package
swift build

# Run tests (if available)
swift test
```

#### Using Xcode

1. Open the project in Xcode:
   ```bash
   open Package.swift
   ```

2. Wait for Swift Package Manager to resolve dependencies

3. Select the WhosOnCall scheme

4. Choose your target device (iPhone 15 Simulator recommended)

5. Press ⌘R to build and run

## Usage

### Authentication

1. Launch the app
2. Enter your email and password
3. Tap "Sign In" to log in
4. Or tap "Create Account" to register a new user

### Viewing Schedules

1. Navigate to the "Schedules" tab
2. Use the search bar to find specific providers
3. Filter by specialty or healthcare plan using the filter menus
4. Pull down to refresh the list

### Provider Directory

1. Navigate to the "Directory" tab
2. Search for providers by name or specialty
3. Tap the phone number to initiate a call
4. Pull down to refresh the list

### Settings

1. Navigate to the "Settings" tab
2. View your account information
3. Tap "Sign Out" to log out

## Key Features

### Debounced Search
Search queries are debounced by 500ms to optimize API calls and improve performance.

### Filter Builder Pattern
DataService uses a safe builder pattern for constructing Supabase queries:
- `.eq()` for exact matches
- `.ilike()` for case-insensitive pattern matching
- `.order()` for sorting results

### Session Management
SessionController singleton listens to Supabase auth events and automatically updates the app state when users sign in or out.

### Environment Objects
SessionController is injected as an environment object, making it accessible throughout the view hierarchy.

## Customization

### Adding New Filters

To add new filter options in ScheduleListView:

```swift
Button("New Specialty") {
    viewModel.selectedSpecialty = "New Specialty"
}
```

### Modifying Table Names

If your Supabase tables have different names, update the queries in `DataService.swift`:

```swift
.from("your_table_name")
```

## Troubleshooting

### Build Errors
- Ensure you're using Xcode 15+ and Swift 5.9+
- Clean build folder: Product > Clean Build Folder (⇧⌘K)
- Reset package cache: File > Packages > Reset Package Caches

### Authentication Issues
- Verify Supabase URL and API key are correct
- Check that your Supabase project's authentication is enabled
- Ensure email confirmation is disabled for development (Supabase > Authentication > Settings)

### Data Not Loading
- Verify RLS policies are configured correctly
- Check that you're authenticated
- Review Supabase logs for errors

## Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for search debouncing
- **Supabase**: Backend-as-a-Service for auth and database
- **PostgREST**: RESTful API interface to Supabase database
- **Swift Concurrency**: Async/await for modern asynchronous code

## License

This project is provided as-is for educational and commercial use.

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review Supabase documentation at [supabase.com/docs](https://supabase.com/docs)
3. Check Swift Package Manager logs for dependency issues

## Future Enhancements

- Push notifications for schedule changes
- Calendar integration
- Export schedules to PDF
- Multi-facility support
- Role-based access control
- Offline mode with local caching
