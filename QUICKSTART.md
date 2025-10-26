# Quick Start Guide

Get WOC (Who's On Call) running in 5 minutes!

---

## ⚡ Prerequisites

- macOS with Xcode 15+
- Supabase account (free at https://app.supabase.com)

---

## 🚀 5-Minute Setup

### Step 1: Clone and Open (30 seconds)

```bash
# Already cloned? Just open it
cd IOSWOC
open WhosOnCall.xcodeproj
```

Wait for Swift Package Manager to download dependencies (~1-2 minutes first time).

---

### Step 2: Create Supabase Project (2 minutes)

1. Go to https://app.supabase.com
2. Click "New Project"
3. Enter:
   - Name: `woc-app`
   - Password: (create one)
   - Region: (choose closest)
4. Click "Create" and wait ~1 minute

---

### Step 3: Set Up Database (1 minute)

In Supabase dashboard:

1. Go to **SQL Editor** (left sidebar)
2. Click **New Query**
3. Paste and run:

```sql
-- Create schedules table
CREATE TABLE schedules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  specialty TEXT NOT NULL,
  provider TEXT NOT NULL,
  healthcare_plan TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read schedules"
  ON schedules FOR SELECT TO authenticated USING (true);

-- Create directory table
CREATE TABLE directory (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  provider_name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  phone_number TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE directory ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read directory"
  ON directory FOR SELECT TO authenticated USING (true);

-- Add sample data
INSERT INTO schedules (date, specialty, provider, healthcare_plan) VALUES
  ('2025-01-15', 'Cardiology', 'Dr. Sarah Johnson', 'HMO'),
  ('2025-01-15', 'Emergency Medicine', 'Dr. Michael Chen', 'PPO'),
  ('2025-01-16', 'Surgery', 'Dr. Emily Rodriguez', 'HMO');

INSERT INTO directory (provider_name, specialty, phone_number) VALUES
  ('Dr. Sarah Johnson', 'Cardiology', '(555) 123-4567'),
  ('Dr. Michael Chen', 'Emergency Medicine', '(555) 234-5678'),
  ('Dr. Emily Rodriguez', 'Surgery', '(555) 345-6789');
```

---

### Step 4: Get Credentials (30 seconds)

In Supabase dashboard:

1. Click **Settings** (gear icon)
2. Click **API**
3. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGci...`

---

### Step 5: Configure App (30 seconds)

In Xcode:

1. Open `WhosOnCall/Services/SupabaseClientProvider.swift`
2. Replace:

```swift
private let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
private let supabaseKey = "YOUR_SUPABASE_ANON_KEY"
```

With your actual values:

```swift
private let supabaseURL = URL(string: "https://xxxxx.supabase.co")!
private let supabaseKey = "eyJhbGci..."
```

3. Save (⌘S)

---

### Step 6: Create Test User (30 seconds)

In Supabase dashboard:

1. Go to **Authentication** → **Users**
2. Click **Add user** → **Create new user**
3. Enter:
   - Email: `test@example.com`
   - Password: `password123`
4. Click **Create user**

---

### Step 7: Build & Run! (30 seconds)

In Xcode:

1. Select **iPhone 15** simulator (top toolbar)
2. Press **⌘R** or click ▶️ Play button
3. Wait for build and simulator to launch

---

## 🎉 Test the App

1. **Login**: 
   - Email: `test@example.com`
   - Password: `password123`

2. **Explore**:
   - **Schedules Tab**: View on-call schedules, search, filter
   - **Directory Tab**: Browse providers, search
   - **Settings Tab**: View account, sign out

---

## 📚 More Information

- **Detailed Setup**: See [SETUP.md](SETUP.md)
- **Implementation**: See [IMPLEMENTATION.md](IMPLEMENTATION.md)
- **Testing Guide**: See [TESTING.md](TESTING.md)

---

## ⚠️ Troubleshooting

### Build Fails
```bash
# Clean and rebuild
Product → Clean Build Folder (⌘⇧K)
Product → Build (⌘B)
```

### Can't Sign In
- Check Supabase URL and key are correct
- Verify test user exists in Supabase
- Check internet connection

### No Data Shows
- Verify sample data was inserted
- Check RLS policies are set
- Confirm you're signed in

---

## 🎯 You're Done!

The app should now be running with:
- ✅ Authentication working
- ✅ Schedules loading
- ✅ Directory browsing
- ✅ Search functioning

**Next**: Customize for your hospital's needs!
