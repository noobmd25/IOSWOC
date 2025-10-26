# GitHub Copilot Instructions for IOSWOC

This repository contains WOC (Who's On Call), an iOS application for on-call management in hospitals and ED teams. The app is built with SwiftUI and powered by Supabase.

## Project Overview

WOC streamlines on-call management by providing:
- Real-time schedule viewing
- Specialty and healthcare plan filtering
- Updated provider directory with quick-dial links
- Fast, secure SwiftUI interface

## Code Style Guidelines

### Swift & SwiftUI
- Follow Swift API Design Guidelines and Apple's Swift style guide
- Use SwiftUI declarative syntax for all UI components
- Prefer `struct` over `class` for views and view models where possible
- Use meaningful, descriptive names for variables, functions, and types
- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
- Use `private` and `fileprivate` access control appropriately to encapsulate implementation details
- Prefer protocol-oriented programming where appropriate
- Use Swift's native optionals and avoid force unwrapping (`!`) unless absolutely necessary

### Code Organization
- Group related code using `// MARK: - Section Name`
- Keep view files focused and under 200 lines when possible
- Extract complex views into separate components
- Use view modifiers to keep views clean and reusable

### Formatting
- Use 4 spaces for indentation (not tabs)
- Maximum line length of 120 characters
- Add blank lines to separate logical sections
- Use trailing commas in multi-line arrays and dictionaries

## Architecture & Patterns

### MVVM Pattern
- Separate business logic from UI using ViewModels
- Use `@StateObject` for ViewModel ownership
- Use `@ObservedObject` when passing ViewModels down the hierarchy
- Keep Views lightweight and focused on UI rendering

### State Management
- Use `@State` for view-local state
- Use `@Binding` to pass state to child views
- Use `@Published` in ViewModels for observable properties
- Consider using `@AppStorage` for user preferences
- Use `@EnvironmentObject` for shared app-wide state

### Backend Integration (Supabase)
- Keep all Supabase API calls in dedicated service layers
- Use async/await for asynchronous operations
- Handle errors gracefully with proper error types
- Never expose API keys or secrets in code

## Security Guidelines

### Data Protection
- Never commit API keys, secrets, or credentials to the repository
- Store sensitive configuration in environment variables or secure key storage
- Use Keychain for storing sensitive user data
- Implement proper authentication and authorization checks

### User Privacy
- Handle healthcare data with HIPAA compliance in mind
- Implement proper data encryption for sensitive information
- Request minimal permissions necessary
- Provide clear privacy policy and data handling information

### Network Security
- Use HTTPS for all network communications
- Implement certificate pinning if communicating with Supabase
- Validate and sanitize all user inputs
- Handle authentication tokens securely

## Testing Guidelines

### Unit Tests
- Write unit tests for ViewModels and business logic
- Aim for at least 70% code coverage for critical paths
- Use XCTest framework for testing
- Mock external dependencies (network calls, database)
- Test edge cases and error handling

### UI Tests
- Write UI tests for critical user flows
- Test accessibility features
- Verify proper error message display
- Test different device sizes and orientations

### Test Organization
- Name tests descriptively: `test_featureName_scenario_expectedResult`
- Keep tests focused on a single behavior
- Use setup and teardown methods appropriately
- Use test fixtures for common data

## Documentation

### Code Comments
- Use `///` for public API documentation
- Include parameter descriptions and return values
- Document complex algorithms or business logic
- Avoid obvious comments; let code be self-documenting when possible

### README and Documentation
- Keep README.md up to date with setup instructions
- Document API integrations and configuration
- Include screenshots for UI changes
- Document known issues and workarounds

## Dependencies

### Dependency Management
- Use Swift Package Manager (SPM) for dependencies
- Keep dependencies up to date with security patches
- Document why each dependency is needed
- Prefer native iOS frameworks when possible
- Minimize third-party dependencies

### Supabase Integration
- Use official Supabase Swift SDK
- Keep SDK version consistent across the project
- Document Supabase schema and API usage

## Accessibility

- Support Dynamic Type for all text
- Provide meaningful accessibility labels for UI elements
- Ensure sufficient color contrast ratios (WCAG AA minimum)
- Support VoiceOver navigation
- Test with accessibility features enabled

## Performance

- Use lazy loading for lists and large data sets
- Optimize images and assets
- Cache frequently accessed data appropriately
- Profile and optimize performance bottlenecks
- Use instruments to detect memory leaks

## Version Control

- Write clear, descriptive commit messages
- Keep commits focused and atomic
- Use conventional commit format when possible
- Update PR descriptions with meaningful context
- Reference issue numbers in commits and PRs

## Healthcare Domain Specific

### Medical Terminology
- Use correct medical terminology and abbreviations
- Document specialty codes and healthcare plan types
- Ensure accuracy when displaying provider information

### Scheduling
- Handle time zones correctly for on-call schedules
- Account for shift changes and coverage periods
- Validate schedule conflicts

### Provider Directory
- Ensure contact information is up-to-date and accurate
- Implement quick-dial functionality safely
- Handle emergency contact scenarios appropriately

## Error Handling

- Use Swift's Result type for operations that can fail
- Provide user-friendly error messages
- Log errors appropriately for debugging
- Implement graceful degradation when services are unavailable
- Show loading states during async operations

## Best Practices

- Follow the principle of least surprise
- Write idiomatic Swift code
- Keep functions small and focused
- Use Swift's type system to prevent bugs
- Prefer composition over inheritance
- Write self-documenting code with clear naming
- Consider edge cases and error scenarios
- Test on both iPhone and iPad when applicable
