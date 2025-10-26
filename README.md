# WOC (Who's On Call)

A hospital on-call scheduling and provider directory app built with SwiftUI and Supabase.

## Description

WOC (Who's On Call) streamlines on-call management for hospitals and ED teams. View real-time schedules, filter by specialty or healthcare plan, and access an updated provider directory with quick-dial links—all in a fast, secure SwiftUI app powered by Supabase.

## Features

- 📅 **Schedule Management**: View on-call schedules with filtering by specialty and healthcare plan
- 👥 **Provider Directory**: Searchable directory with tap-to-call functionality
- 🔐 **Secure Authentication**: Email/password login via Supabase
- 🔍 **Smart Search**: Debounced search for better performance
- 🔄 **Pull-to-Refresh**: Always get the latest data
- 🌓 **Dark Mode**: Full support for light and dark themes
- 📱 **iOS 16+**: Modern SwiftUI interface

## Quick Start

1. **Clone the repository**
2. **Open `WhosOnCall.xcodeproj` in Xcode 15+**
3. **Follow the setup guide in [SETUP.md](SETUP.md)**
4. **Configure your Supabase credentials**
5. **Build and run on iOS 16+ simulator or device**

## Architecture

- **MVVM Pattern**: Separation of concerns with Models, Views, ViewModels, and Services
- **SwiftUI**: Modern declarative UI framework
- **Combine**: Reactive programming for search debouncing
- **Supabase**: Backend authentication and real-time database

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Supabase account (free tier available)

## Documentation

See [SETUP.md](SETUP.md) for detailed setup instructions including:
- Supabase project configuration
- Database table creation
- Authentication setup
- Building and running the app

## Project Structure

```
WhosOnCall/
├── Models/              # Data models (Schedule, DirectoryEntry)
├── Views/               # SwiftUI views
├── ViewModels/          # View models with business logic
├── Services/            # API and session management
└── Resources/           # Assets and resources
```

## License

This project is provided as-is for hospital on-call scheduling purposes.
