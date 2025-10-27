# Quick Start Guide - WOC iOS App

Get up and running with the WOC iOS app in 5 minutes!

## Prerequisites

- macOS with Xcode 15.0+
- Supabase account (free tier is fine)
- iOS 16+ device or simulator

## Step 1: Clone Repository (30 seconds)

```bash
git clone https://github.com/noobmd25/IOSWOC.git
cd IOSWOC
```

## Step 2: Get Supabase Credentials (2 minutes)

1. Go to https://supabase.com and sign in
2. Create a new project (or use existing)
3. Navigate to Settings → API
4. Copy:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGci...`

## Step 3: Configure App (1 minute)

Edit `WhosOnCall/Services/SupabaseClientProvider.swift`:

```swift
// Replace these lines (around line 8-9):
private let supabaseURL = URL(string: "https://YOUR_PROJECT_ID.supabase.co")!
private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

// With your actual credentials:
private let supabaseURL = URL(string: "https://xxxxx.supabase.co")!
private let supabaseAnonKey = "eyJhbGci..."
```

## Step 4: Setup Database (2 minutes)

In Supabase SQL Editor, run these commands:

```sql
-- 1. Create tables
CREATE TABLE specialties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE healthcare_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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

CREATE TABLE schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE NOT NULL,
    specialty_id UUID REFERENCES specialties(id),
    provider_id UUID REFERENCES directory(id),
    healthcare_plan_id UUID REFERENCES healthcare_plans(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    role TEXT NOT NULL DEFAULT 'viewer' CHECK (role IN ('viewer', 'scheduler', 'admin')),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE specialties ENABLE ROW LEVEL SECURITY;
ALTER TABLE healthcare_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE directory ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- 3. Create policies
CREATE POLICY "Allow read access to authenticated users" ON specialties FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow read access to authenticated users" ON healthcare_plans FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow read access to authenticated users" ON directory FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow read access to authenticated users" ON schedules FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow users to read their own profile" ON profiles FOR SELECT TO authenticated USING (auth.uid() = id);

-- 4. Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE schedules;
ALTER PUBLICATION supabase_realtime ADD TABLE directory;

-- 5. Add sample data
INSERT INTO specialties (name, slug) VALUES
    ('Internal Medicine', 'internal-medicine'),
    ('Emergency Medicine', 'emergency-medicine'),
    ('Surgery', 'surgery');

INSERT INTO healthcare_plans (name, slug) VALUES
    ('Medicare', 'medicare'),
    ('Medicaid', 'medicaid');

INSERT INTO directory (provider_name, specialty_id, phone_number, resident_phone, color_hex)
SELECT 'Dr. Sarah Johnson', id, '555-0101', '555-0102', '#3498db'
FROM specialties WHERE slug = 'internal-medicine';

INSERT INTO schedules (date, specialty_id, provider_id, healthcare_plan_id)
SELECT CURRENT_DATE, s.id, d.id, h.id
FROM specialties s, directory d, healthcare_plans h
WHERE s.slug = 'internal-medicine' LIMIT 1;
```

## Step 5: Create Test User (1 minute)

1. In Supabase: Authentication → Users → Add user
2. Create user:
   - Email: `test@example.com`
   - Password: `TestPassword123!`
   - Auto Confirm: ✓ (checked)
3. Copy the user's UUID
4. In SQL Editor:

```sql
-- Replace USER_UUID with the actual UUID
INSERT INTO profiles (id, role, status)
VALUES ('USER_UUID', 'viewer', 'active');
```

## Step 6: Run App (1 minute)

1. Open project:
```bash
open WhosOnCall.xcodeproj
```

2. Wait for packages to resolve (status bar)
3. Select "iPhone 15" simulator (or your device)
4. Press `Cmd + R` to build and run
5. Login with:
   - Email: `test@example.com`
   - Password: `TestPassword123!`

## Done! 🎉

You should now see:
- **On-Call tab**: Your sample schedule
- **Directory tab**: Dr. Sarah Johnson
- **Settings tab**: Your user info

## Next Steps

- Add more providers and schedules
- Customize provider colors
- Add your team members as users
- Explore filters and search

## Troubleshooting

**Build fails?**
- File → Packages → Reset Package Caches
- Clean Build Folder (Cmd + Shift + K)

**Can't sign in?**
- Check Supabase URL and key in SupabaseClientProvider.swift
- Verify user exists in Authentication → Users
- Ensure profile exists in profiles table

**No data appears?**
- Check RLS policies are created
- Verify sample data was inserted
- Check Supabase logs for errors

## Full Documentation

For detailed instructions, see:
- **SETUP_GUIDE.md**: Complete setup with explanations
- **IMPLEMENTATION.md**: Technical architecture details
- **README.md**: Project overview and features

## Support

Need help? Check:
- GitHub Issues: https://github.com/noobmd25/IOSWOC/issues
- Supabase Docs: https://supabase.com/docs

---

**Total Time**: ~7 minutes to working app
**Difficulty**: Beginner-friendly
**Requirements**: macOS, Xcode, Supabase account
