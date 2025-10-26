# WOC (Who's On Call) - Quick Start Guide

## What You've Got

A complete, production-ready SwiftUI iOS application for hospital on-call scheduling with:

✅ **16 Swift source files** organized in MVVM architecture  
✅ **Supabase integration** for authentication and real-time data  
✅ **Professional UI/UX** with search, filters, and pull-to-refresh  
✅ **iOS 16+** compatibility with modern Swift features  

## File Organization

```
WhosOnCall/
├── Main/                          # App entry point
│   ├── WhosOnCallApp.swift       # @main entry - starts here
│   ├── ContentView.swift          # Root container with environment
│   └── RootView.swift             # Routes to Login or MainTab
│
├── Views/                         # All UI screens
│   ├── LoginView.swift           # Email/password authentication
│   ├── MainTabView.swift         # Tab navigation (3 tabs)
│   ├── ScheduleListView.swift   # Schedule list with filters
│   ├── DirectoryListView.swift  # Provider directory with search
│   └── SettingsView.swift        # Settings and sign out
│
├── ViewModels/                    # Business logic layer
│   ├── AuthViewModel.swift       # Login/signup logic
│   ├── ScheduleViewModel.swift   # Schedule data + filters
│   └── DirectoryViewModel.swift  # Directory data + search
│
├── Services/                      # Backend integration
│   ├── SupabaseClientProvider.swift  # Supabase singleton
│   ├── SessionController.swift       # Auth state management
│   └── DataService.swift             # Database queries
│
└── Models/                        # Data structures
    ├── Schedule.swift            # Schedule entry model
    └── DirectoryEntry.swift      # Directory entry model
```

## How to Build & Run

### Prerequisites
- **macOS** (Monterey or later recommended)
- **Xcode 15.0+** ([Download here](https://developer.apple.com/xcode/))
- **Supabase account** ([Sign up free](https://supabase.com))

### Step 1: Open in Xcode

```bash
cd /path/to/IOSWOC
open Package.swift
```

Xcode will automatically:
- Resolve Swift Package dependencies (supabase-swift + deps)
- Set up the build environment
- Configure the iOS simulator

### Step 2: Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)

2. Get your credentials:
   - Go to **Settings** → **API**
   - Copy **Project URL** (looks like `https://xxxxx.supabase.co`)
   - Copy **anon public** key

3. Update `WhosOnCall/Services/SupabaseClientProvider.swift`:

```swift
let supabaseURL = URL(string: "https://YOUR-PROJECT.supabase.co")!
let supabaseKey = "YOUR-ANON-KEY-HERE"
```

### Step 3: Set Up Database Tables

In Supabase SQL Editor, run:

```sql
-- Create tables
CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    specialty TEXT NOT NULL,
    provider TEXT NOT NULL,
    healthcare_plan TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE directory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_name TEXT NOT NULL,
    specialty TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE directory ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read data
CREATE POLICY "Users can read schedules"
    ON schedules FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can read directory"
    ON directory FOR SELECT TO authenticated USING (true);

-- Add sample data
INSERT INTO schedules (date, specialty, provider, healthcare_plan) VALUES
    (NOW() + INTERVAL '1 day', 'Cardiology', 'Dr. Sarah Johnson', 'Medicare'),
    (NOW() + INTERVAL '2 days', 'Emergency Medicine', 'Dr. Michael Chen', 'Medicaid'),
    (NOW() + INTERVAL '3 days', 'Orthopedics', 'Dr. Emily Davis', 'Private');

INSERT INTO directory (provider_name, specialty, phone_number) VALUES
    ('Dr. Sarah Johnson', 'Cardiology', '(555) 123-4567'),
    ('Dr. Michael Chen', 'Emergency Medicine', '(555) 234-5678'),
    ('Dr. Emily Davis', 'Orthopedics', '(555) 345-6789');
```

### Step 4: Create a Test User

In Supabase:
1. Go to **Authentication** → **Users**
2. Click **Add User**
3. Add email: `test@example.com`, password: `test123456`
4. Or use the app's "Create Account" button

### Step 5: Build & Run

1. In Xcode, select **WhosOnCall** scheme
2. Choose target: **iPhone 15** (or any iOS 16+ simulator)
3. Press **⌘R** or click the Play button
4. Wait for build to complete (~30-60 seconds first time)

### Step 6: Test the App

1. **Login:** Use your test credentials
2. **Schedules Tab:** 
   - Search for providers
   - Filter by specialty (Cardiology, Emergency Medicine, etc.)
   - Filter by healthcare plan (Medicare, Medicaid, Private)
   - Pull down to refresh
3. **Directory Tab:**
   - Search providers by name or specialty
   - Tap phone numbers to call (simulator will show alert)
   - Pull down to refresh
4. **Settings Tab:**
   - View account info
   - Sign out

## Key Features Explained

### 🔍 Debounced Search
Search queries wait 500ms after you stop typing before hitting the API. This prevents excessive API calls and improves performance.

### 🎯 Smart Filters
Combine filters (specialty + healthcare plan) work together. Changes are automatically applied without a "submit" button.

### ↻ Pull-to-Refresh
Pull down on any list to manually refresh data from Supabase.

### 🔐 Automatic Session Management
The `SessionController` listens to Supabase auth events and automatically:
- Shows LoginView when signed out
- Shows MainTabView when signed in
- No manual state management needed

### 📞 Tap-to-Call
Phone numbers in the directory are live links. Tapping opens the Phone app (on real devices).

### 🌓 Dark Mode
The app automatically adapts to system dark/light mode preferences.

## Architecture Highlights

### MVVM Pattern
- **Models:** Pure data structures (Schedule, DirectoryEntry)
- **Views:** SwiftUI components (read-only, declarative)
- **ViewModels:** Business logic and state (@Published properties)

### Dependency Injection
`SessionController` is injected as `@EnvironmentObject`, making it accessible throughout the view hierarchy without prop drilling.

### Combine Framework
Used for:
- Debouncing search text
- Reactive filter updates
- State management

### Async/Await
All network calls use modern Swift concurrency:
```swift
Task {
    await viewModel.loadSchedules()
}
```

## Customization Guide

### Add New Specialty
In `ScheduleListView.swift`, add to the specialty menu:
```swift
Button("Neurology") {
    viewModel.selectedSpecialty = "Neurology"
}
```

### Change Debounce Time
In ViewModels, adjust the debounce duration:
```swift
.debounce(for: .milliseconds(300), scheduler: RunLoop.main)  // Faster response
```

### Add New Fields
1. Update the model (e.g., `Schedule.swift`)
2. Update the database table in Supabase
3. Update the UI row component

### Change Theme Colors
SwiftUI uses semantic colors that adapt to light/dark mode:
- `.blue` - Primary actions
- `.green` - Success/call actions
- `.red` - Destructive actions

## Troubleshooting

### "No such module 'SwiftUI'"
This error occurs when building on Linux. SwiftUI is Apple-exclusive. Build on macOS with Xcode.

### Dependencies Won't Resolve
```bash
# In Xcode:
File → Packages → Reset Package Caches
File → Packages → Update to Latest Package Versions
```

### Authentication Fails
- Verify Supabase URL and key are correct
- Check your internet connection
- Ensure email confirmation is disabled in Supabase Auth settings

### No Data Appears
- Verify you've run the SQL setup script
- Check RLS policies allow reading
- Make sure you're signed in (check Settings tab)

### Build Errors
```bash
# Clean build:
⇧⌘K (Shift-Command-K)

# Then rebuild:
⌘B (Command-B)
```

## Production Checklist

Before deploying to TestFlight/App Store:

- [ ] Update Supabase URL and keys (store in environment variables)
- [ ] Set proper RLS policies (restrict data access as needed)
- [ ] Add app icon (Assets.xcassets/AppIcon.appiconset)
- [ ] Configure bundle identifier (com.yourcompany.whosonc call)
- [ ] Set version and build numbers
- [ ] Test on physical devices
- [ ] Add error analytics (e.g., Sentry)
- [ ] Implement rate limiting for API calls
- [ ] Add offline mode with local caching
- [ ] Write unit tests for ViewModels
- [ ] Add UI tests for critical flows

## Additional Resources

- **Complete Setup:** See [SETUP.md](SETUP.md)
- **Supabase Docs:** https://supabase.com/docs
- **SwiftUI Tutorials:** https://developer.apple.com/tutorials/swiftui
- **Swift Concurrency:** https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html

## Support

If you encounter issues:

1. Check this guide's Troubleshooting section
2. Review SETUP.md for detailed instructions
3. Run `./validate.sh` to verify file structure
4. Check Supabase logs for backend errors
5. Review Xcode console for runtime errors

## What's Next?

Suggested enhancements:
- Push notifications for schedule changes
- Calendar export (iCal format)
- Role-based access (admin vs. user)
- Multi-facility support
- Profile pictures for providers
- Shift swap requests
- Real-time updates with Supabase Realtime

---

**Built with:**
- SwiftUI (iOS 16+)
- Supabase (Auth + Database)
- Combine (Reactive programming)
- Swift 5.9+ (Modern concurrency)

Happy coding! 🚀
