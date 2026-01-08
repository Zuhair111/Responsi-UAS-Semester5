-- ============================================
-- MIGRATION: Add Username Field to Profiles
-- Run this in Supabase SQL Editor if you already have the profiles table
-- ============================================

-- 1. Add username column to profiles table (if not exists)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;

-- 2. Update existing profiles to generate username from email
UPDATE profiles 
SET username = SPLIT_PART(email, '@', 1)
WHERE username IS NULL;

-- 3. Make username NOT NULL after filling existing records
ALTER TABLE profiles ALTER COLUMN username SET NOT NULL;

-- 4. Update the trigger function to include username
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO profiles (id, username, name, email, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- IMPORTANT NOTES:
-- ============================================
-- 1. Jika Anda baru setup database, gunakan supabase_setup.sql
-- 2. Jika database sudah ada, gunakan file migration ini
-- 3. Username akan otomatis diambil dari bagian sebelum @ di email
-- 4. Username tidak bisa diubah setelah dibuat (UNIQUE dan permanent)
-- 5. Nama (name) bisa diubah melalui edit profile
