# WOC (Who's On Call)

[![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-15.0%2B-blue.svg)](https://developer.apple.com/xcode/)
[![Supabase](https://img.shields.io/badge/Supabase-2.0%2B-green.svg)](https://supabase.com)

**WOC (Who's On Call)** streamlines on-call management for hospitals and ED teams. View real-time schedules, filter by specialty or healthcare plan, and access an updated provider directory with quick-dial links—all in a fast, secure SwiftUI app powered by Supabase.

## ✨ Features

- 🔐 **Secure Authentication** - Email/password login via Supabase
- 📅 **Schedule Management** - View and filter on-call schedules
- 🔍 **Smart Search** - Debounced search for optimal performance
- 📖 **Provider Directory** - Searchable directory with tap-to-call
- 🔄 **Real-time Sync** - Live data from Supabase database
- 🎯 **Advanced Filtering** - Filter by specialty and healthcare plan
- ↻ **Pull-to-Refresh** - Easy manual data refresh
- 🌓 **Dark Mode** - Full light/dark mode support
- 📱 **iOS 16+** - Modern SwiftUI implementation

## 🚀 Quick Start

### Prerequisites
- macOS (Monterey or later)
- Xcode 15.0+
- Supabase account

### 1. Clone and Open

```bash
git clone https://github.com/noobmd25/IOSWOC.git
cd IOSWOC
open Package.swift
```

### 2. Configure Supabase

Edit `WhosOnCall/Services/SupabaseClientProvider.swift`:

```swift
let supabaseURL = URL(string: "https://YOUR-PROJECT.supabase.co")!
let supabaseKey = "YOUR-ANON-KEY-HERE"
```

### 3. Set Up Database

Run the SQL in [SETUP.md](SETUP.md) to create tables and sample data.

### 4. Build & Run

Press **⌘R** in Xcode to build and run on the simulator.

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Detailed setup guide with screenshots
- **[SETUP.md](SETUP.md)** - Complete setup instructions and SQL scripts
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Architecture diagrams and design patterns

## 🏗️ Project Structure

```
WhosOnCall/
├── Main/              # App entry point
├── Views/             # SwiftUI views
├── ViewModels/        # Business logic
├── Services/          # Backend integration
└── Models/            # Data models
```

**16 Swift files** organized in clean MVVM architecture.

## 🛠️ Tech Stack

- **SwiftUI** - Declarative UI framework
- **Combine** - Reactive programming for debouncing
- **Supabase** - Backend-as-a-Service (Auth + Database)
- **PostgREST** - RESTful API for database queries
- **Swift Concurrency** - Modern async/await

## 📱 Screenshots

The app features three main tabs:

1. **Schedules** - View and filter on-call schedules
2. **Directory** - Browse providers with search and call
3. **Settings** - Account management and sign out

## 🔒 Security

- Row Level Security (RLS) policies on all tables
- JWT-based authentication
- Secure API key management
- No sensitive data in source control

## 🧪 Testing

Run the validation script:

```bash
./validate.sh
```

This verifies all source files are present and the project structure is correct.

## 🤝 Contributing

This is a reference implementation for hospital on-call scheduling. Feel free to fork and customize for your needs.

## 📄 License

This project is provided as-is for educational and commercial use.

## 🙏 Acknowledgments

- Built with [Supabase](https://supabase.com) for backend services
- Uses [supabase-swift](https://github.com/supabase/supabase-swift) SDK
- Designed for real-world hospital workflows

## 📞 Support

For issues or questions:
1. Check the [QUICKSTART.md](QUICKSTART.md) troubleshooting section
2. Review [SETUP.md](SETUP.md) for detailed instructions
3. See [ARCHITECTURE.md](ARCHITECTURE.md) for design details

---

**Made with ❤️ for healthcare teams**
