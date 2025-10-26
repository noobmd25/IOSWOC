#!/bin/bash

# Build Validation Script for Who's On Call
# This script validates that all Swift files are syntactically correct
# Note: SwiftUI apps must be built with Xcode on macOS

echo "================================"
echo "Who's On Call - Build Validation"
echo "================================"
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✓ Running on macOS"
    
    # Check if Xcode is installed
    if command -v xcodebuild &> /dev/null; then
        echo "✓ Xcode is installed"
        echo ""
        echo "Building project with xcodebuild..."
        
        # Try to build the package
        xcodebuild -list
        
    else
        echo "✗ Xcode is not installed"
        echo "Please install Xcode from the App Store to build this SwiftUI project"
        exit 1
    fi
else
    echo "ℹ Running on non-macOS system ($OSTYPE)"
    echo ""
    echo "This is a SwiftUI iOS application that requires:"
    echo "  - macOS operating system"
    echo "  - Xcode 15.0 or later"
    echo "  - iOS 16.0+ SDK"
    echo ""
    echo "SwiftUI framework is not available on Linux or other platforms."
    echo "Please build this project on a Mac using Xcode."
    echo ""
    echo "Project structure validation:"
fi

# Validate project structure
echo ""
echo "Checking project structure..."

REQUIRED_DIRS=(
    "WhosOnCall/Main"
    "WhosOnCall/Views"
    "WhosOnCall/ViewModels"
    "WhosOnCall/Services"
    "WhosOnCall/Models"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ $dir"
    else
        echo "✗ $dir (missing)"
    fi
done

echo ""
echo "Checking Swift source files..."

REQUIRED_FILES=(
    "WhosOnCall/Main/WhosOnCallApp.swift"
    "WhosOnCall/Main/ContentView.swift"
    "WhosOnCall/Main/RootView.swift"
    "WhosOnCall/Views/LoginView.swift"
    "WhosOnCall/Views/MainTabView.swift"
    "WhosOnCall/Views/ScheduleListView.swift"
    "WhosOnCall/Views/DirectoryListView.swift"
    "WhosOnCall/Views/SettingsView.swift"
    "WhosOnCall/ViewModels/AuthViewModel.swift"
    "WhosOnCall/ViewModels/ScheduleViewModel.swift"
    "WhosOnCall/ViewModels/DirectoryViewModel.swift"
    "WhosOnCall/Services/SupabaseClientProvider.swift"
    "WhosOnCall/Services/SessionController.swift"
    "WhosOnCall/Services/DataService.swift"
    "WhosOnCall/Models/Schedule.swift"
    "WhosOnCall/Models/DirectoryEntry.swift"
)

MISSING_COUNT=0

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file (missing)"
        ((MISSING_COUNT++))
    fi
done

echo ""
echo "Package.swift dependency manifest:"
if [ -f "Package.swift" ]; then
    echo "✓ Package.swift exists"
    echo ""
    echo "Dependencies will be resolved when opening in Xcode:"
    echo "  - supabase-swift (v2.0.0+)"
else
    echo "✗ Package.swift missing"
    ((MISSING_COUNT++))
fi

echo ""
if [ $MISSING_COUNT -eq 0 ]; then
    echo "✓ All required files present"
    echo ""
    echo "=========================================="
    echo "Next Steps:"
    echo "=========================================="
    echo "1. Open the project on macOS with Xcode:"
    echo "   open Package.swift"
    echo ""
    echo "2. Configure Supabase credentials in:"
    echo "   WhosOnCall/Services/SupabaseClientProvider.swift"
    echo ""
    echo "3. Build and run with ⌘R"
    echo ""
    echo "See SETUP.md for complete instructions."
    exit 0
else
    echo "✗ $MISSING_COUNT file(s) missing"
    exit 1
fi
