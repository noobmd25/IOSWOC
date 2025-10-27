# WOC iOS App - Setup Guide

This guide walks you through setting up the complete WOC (Who's On Call) iOS application with Supabase backend.

## Prerequisites

- macOS with Xcode 15.0 or later
- An active Supabase account
- Basic familiarity with iOS development

## Step 1: Supabase Project Setup

### 1.1 Create a New Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign in or create an account
3. Click "New Project"
4. Enter project details:
   - Name: `woc-ios`
   - Database Password: (choose a strong password)
   - Region: (select nearest region)
5. Click "Create new project"
6. Wait for the project to be ready (this may take a few minutes)

### 1.2 Get Your API Credentials

1. In your Supabase project dashboard, click on "Settings" (gear icon in the sidebar)
2. Click on "API" in the settings menu
3. Note down these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGci...` (long JWT token)

## Step 2: Database Schema Setup

### 2.1 Access the SQL Editor

1. In your Supabase project, click on "SQL Editor" in the left sidebar
2. Click "New Query"

### 2.2 Create Tables

Paste and run the following SQL commands one by one:

#### Create Specialties Table

```sql
CREATE TABLE specialties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Create Healthcare Plans Table

```sql
CREATE TABLE healthcare_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Create Directory Table

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

#### Create Schedules Table

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

#### Create Profiles Table

```sql
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    role TEXT NOT NULL DEFAULT 'viewer' CHECK (role IN ('viewer', 'scheduler', 'admin')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2.3 Enable Row Level Security

Run the following commands to enable RLS:

```sql
ALTER TABLE specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE healthcare_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE directory ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
```

### 2.4 Create RLS Policies

Run these commands to allow read-only access for authenticated users:

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

### 2.5 Enable Realtime

```sql
-- Enable realtime on schedules table
ALTER PUBLICATION supabase_realtime ADD TABLE schedules;

-- Enable realtime on directory table
ALTER PUBLICATION supabase_realtime ADD TABLE directory;
```

## Step 3: Sample Data (Optional)

Insert sample data to test the application:

### Add Sample Specialties

```sql
INSERT INTO specialties (name, slug) VALUES
    ('Internal Medicine', 'internal-medicine'),
    ('Emergency Medicine', 'emergency-medicine'),
    ('Surgery', 'surgery'),
    ('Cardiology', 'cardiology'),
    ('Pediatrics', 'pediatrics');
```

### Add Sample Healthcare Plans

```sql
INSERT INTO healthcare_plans (name, slug) VALUES
    ('Medicare', 'medicare'),
    ('Medicaid', 'medicaid'),
    ('Private Insurance', 'private-insurance'),
    ('Self Pay', 'self-pay');
```

### Add Sample Providers

```sql
-- Get specialty IDs first
DO $$
DECLARE
    internal_med_id UUID;
    emergency_id UUID;
    surgery_id UUID;
BEGIN
    SELECT id INTO internal_med_id FROM specialties WHERE slug = 'internal-medicine';
    SELECT id INTO emergency_id FROM specialties WHERE slug = 'emergency-medicine';
    SELECT id INTO surgery_id FROM specialties WHERE slug = 'surgery';

    INSERT INTO directory (provider_name, specialty_id, phone_number, resident_phone, color_hex) VALUES
        ('Dr. Sarah Johnson', internal_med_id, '555-0101', '555-0102', '#3498db'),
        ('Dr. Michael Chen', emergency_id, '555-0201', '555-0202', '#2ecc71'),
        ('Dr. Emily Rodriguez', surgery_id, '555-0301', '555-0302', '#e74c3c'),
        ('Dr. David Thompson', internal_med_id, '555-0401', NULL, '#f39c12'),
        ('Dr. Lisa Martinez', emergency_id, '555-0501', '555-0502', '#9b59b6');
END $$;
```

### Add Sample Schedules

```sql
-- Create schedules for this week
DO $$
DECLARE
    provider_id UUID;
    specialty_id UUID;
    plan_id UUID;
BEGIN
    -- Get a provider, specialty and plan
    SELECT d.id, d.specialty_id INTO provider_id, specialty_id 
    FROM directory d 
    LIMIT 1;
    
    SELECT id INTO plan_id FROM healthcare_plans LIMIT 1;

    -- Insert schedules for next 7 days
    FOR i IN 0..6 LOOP
        INSERT INTO schedules (date, specialty_id, provider_id, healthcare_plan_id)
        VALUES (
            CURRENT_DATE + i,
            specialty_id,
            provider_id,
            plan_id
        );
    END LOOP;
END $$;
```

## Step 4: Configure Authentication

### 4.1 Enable Email Authentication

1. In Supabase dashboard, go to "Authentication" → "Providers"
2. Ensure "Email" is enabled
3. Configure email settings if needed

### 4.2 Create Test User

1. Go to "Authentication" → "Users"
2. Click "Add user" → "Create new user"
3. Enter:
   - Email: `test@example.com`
   - Password: `TestPassword123!`
   - Auto Confirm User: ✓ (checked)
4. Click "Create user"

### 4.3 Create Profile for Test User

After creating the user, create their profile:

```sql
-- Replace USER_ID with the actual UUID of the test user
INSERT INTO profiles (id, role, status)
VALUES ('USER_ID_FROM_AUTH_USERS', 'viewer', 'active');
```

## Step 5: iOS App Configuration

### 5.1 Clone the Repository

```bash
git clone https://github.com/noobmd25/IOSWOC.git
cd IOSWOC
```

### 5.2 Configure Supabase Credentials

1. Open `WhosOnCall/Services/SupabaseClientProvider.swift`
2. Replace the placeholders:

```swift
private let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
```

With your actual values from Step 1.2:

```swift
private let supabaseURL = URL(string: "https://xxxxx.supabase.co")!
private let supabaseAnonKey = "eyJhbGci..."
```

### 5.3 Open in Xcode

```bash
open WhosOnCall.xcodeproj
```

### 5.4 Wait for Package Resolution

Xcode will automatically download the Supabase Swift package. Wait for this to complete (shown in the status bar).

### 5.5 Select Target Device

1. In Xcode, click on the target dropdown (near the Run button)
2. Select "iPhone 15" or any other iOS 16+ simulator
3. Or select your physical iPhone if connected

### 5.6 Build and Run

1. Press `Cmd + R` or click the Run button
2. Wait for the build to complete
3. The app should launch in the simulator/device

## Step 6: Test the Application

### 6.1 Login

1. Enter the test credentials:
   - Email: `test@example.com`
   - Password: `TestPassword123!`
2. Tap "Sign In"

### 6.2 Explore Features

1. **On-Call Tab**: 
   - View schedules
   - Try the search functionality
   - Use the filter button to filter by specialty/plan
   - Pull down to refresh

2. **Directory Tab**:
   - Browse providers
   - Search for providers
   - Tap phone numbers (in simulator, this won't actually call)

3. **Settings Tab**:
   - View your user ID
   - Sign out and sign back in

## Troubleshooting

### Build Errors

**Issue**: Package resolution fails
- **Solution**: Go to File → Packages → Reset Package Caches, then rebuild

**Issue**: "No such module 'Supabase'"
- **Solution**: Ensure Package.swift is correctly configured and packages are resolved

### Runtime Errors

**Issue**: Authentication fails
- **Solution**: Check your Supabase URL and anon key are correct

**Issue**: No data appears
- **Solution**: 
  1. Verify RLS policies are set up correctly
  2. Check that sample data is inserted
  3. Ensure the user has a profile in the profiles table

**Issue**: Realtime updates not working
- **Solution**: Verify realtime is enabled for schedules and directory tables

### Common Issues

**Issue**: App crashes on launch
- **Solution**: Check Xcode console for error messages, verify Supabase configuration

**Issue**: Search/filter not working
- **Solution**: Ensure you have data in all related tables (specialties, healthcare_plans, directory, schedules)

## Next Steps

1. **Add More Data**: Populate your database with real providers, specialties, and schedules
2. **Customize Colors**: Assign color_hex values to providers for consistent branding
3. **Create Additional Users**: Set up more test accounts with different roles
4. **Configure Notifications**: Set up push notifications (requires additional setup)
5. **Deploy**: Prepare for TestFlight or App Store submission

## Production Considerations

Before deploying to production:

1. **Security**:
   - Review and tighten RLS policies
   - Use environment-specific Supabase projects
   - Never commit API keys to version control

2. **Performance**:
   - Add database indexes for frequently queried columns
   - Consider pagination for large datasets
   - Monitor Supabase usage and optimize queries

3. **Data Management**:
   - Set up regular backups
   - Implement data migration strategies
   - Create admin tools for data management

4. **App Store**:
   - Update bundle identifier
   - Configure proper signing certificates
   - Prepare app metadata and screenshots
   - Submit for review

## Support Resources

- **Supabase Docs**: [https://supabase.com/docs](https://supabase.com/docs)
- **Swift Supabase SDK**: [https://github.com/supabase-community/supabase-swift](https://github.com/supabase-community/supabase-swift)
- **SwiftUI Docs**: [https://developer.apple.com/documentation/swiftui](https://developer.apple.com/documentation/swiftui)
- **GitHub Issues**: [https://github.com/noobmd25/IOSWOC/issues](https://github.com/noobmd25/IOSWOC/issues)

## License

This setup guide is part of the WOC iOS application and is provided as-is for healthcare on-call management purposes.
