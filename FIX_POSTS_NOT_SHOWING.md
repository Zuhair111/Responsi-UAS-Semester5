# 🔧 QUICK FIX: File Sudah Upload Tapi Post Tidak Muncul

## ✅ Masalah Teridentifikasi:
- File **SUDAH** tersimpan di Storage Bucket ✅
- Post **TIDAK** muncul di Home/Profile ❌

## 🎯 Kemungkinan Penyebab:

### 1. Post tidak tersimpan ke table `posts`
### 2. RLS Policy di table `posts` salah
### 3. Fetch posts error

---

## 🚀 SOLUSI CEPAT

### STEP 1: Jalankan SQL Ini di Supabase

Buka **Supabase Dashboard** → **SQL Editor** → Paste dan **RUN**:

```sql
-- =============================================
-- FIX RLS POLICIES - TABLE POSTS
-- =============================================

-- 1. Drop existing policies (jika ada yang salah)
DROP POLICY IF EXISTS "Public posts are viewable by everyone" ON posts;
DROP POLICY IF EXISTS "Users can insert their own posts" ON posts;
DROP POLICY IF EXISTS "Users can update their own posts" ON posts;
DROP POLICY IF EXISTS "Users can delete their own posts" ON posts;
DROP POLICY IF EXISTS "Allow public to read posts" ON posts;
DROP POLICY IF EXISTS "Allow authenticated users to create posts" ON posts;

-- 2. Buat policies yang benar
CREATE POLICY "Enable read access for all users"
ON posts FOR SELECT
USING (true);  -- Semua orang bisa baca (termasuk unauthenticated)

CREATE POLICY "Enable insert for authenticated users only"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);  -- User hanya bisa create post sendiri

CREATE POLICY "Enable update for users based on user_id"
ON posts FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable delete for users based on user_id"
ON posts FOR DELETE
USING (auth.uid() = user_id);

-- 3. Verifikasi policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'posts';
```

**PENTING:** Policy SELECT sekarang menggunakan `USING (true)` agar semua user (termasuk yang belum login) bisa lihat posts!

---

### STEP 2: Cek Data di Table Posts

Jalankan query ini:

```sql
-- Lihat 5 post terakhir
SELECT 
  id,
  user_id,
  content,
  image_url,
  privacy,
  created_at
FROM posts
ORDER BY created_at DESC
LIMIT 5;
```

**Hasil yang Diharapkan:**
- Ada row dengan `image_url` yang terisi
- `image_url` berupa URL lengkap: `https://zmpcueepuevlrkxjiork.supabase.co/storage/v1/object/public/posts/...`

**Jika tidak ada row:**
- Post gagal tersimpan ke database
- Cek console log saat create post
- Kemungkinan ada error "Error creating post"

**Jika ada row tapi `image_url` = null:**
- Upload image berhasil, tapi URL tidak tersimpan
- Bug di create post logic

---

### STEP 3: Test Query Select Posts

```sql
-- Test query yang dipakai aplikasi
SELECT p.*, pr.name, pr.username, pr.avatar_url
FROM posts p
LEFT JOIN profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC
LIMIT 10;
```

**Jika query ini ERROR:**
- Table profiles tidak ada
- Foreign key relationship salah
- Field di profiles tidak lengkap

**Jika query ini BERHASIL:**
- Database OK ✅
- Masalah di aplikasi (fetch atau display)

---

### STEP 4: Restart Aplikasi & Test

1. **Stop** aplikasi
2. **Full restart** (bukan hot reload!)
3. **Login** lagi
4. **Buka home page**
5. **Pull down to refresh**

**Lihat console log:**
```
📥 Fetching posts from database...
📊 Limit: 20, Offset: 0
✅ Database response: X posts
✅ Posts parsed successfully: X posts
```

**Jika `Database response: 0 posts`:**
- Tidak ada data di table posts
- Atau RLS policy SELECT masih salah

**Jika `Error getting posts:`:**
- RLS policy error
- Query error
- Table tidak ada

---

## 🔍 DEBUG: Cek Console Log Saat Create Post

Cari log ini di console:

```
✅ Upload successful!
🔗 Image URL: https://...
📝 Creating post...
💾 Inserting post to database...
```

**Setelah "Inserting post to database...":**

### ✅ Jika Berhasil:
```
✅ Post created successfully!
🆔 Post ID: xyz-123-456
```
**→ Post sudah tersimpan!** Masalah di fetch posts (RLS policy SELECT)

### ❌ Jika Error:
```
❌ Error creating post: PostgrestException...
```
**→ Post TIDAK tersimpan!** RLS policy INSERT bermasalah

---

## 🆘 MANUAL FIX: Insert Post Test

Jika SQL di Step 1 sudah dijalankan tapi masih tidak muncul, test insert manual:

```sql
-- 1. Get your user_id
SELECT id, email FROM auth.users;

-- 2. Insert test post dengan foto dari storage
INSERT INTO posts (
  user_id, 
  content, 
  image_url, 
  privacy, 
  likes_count, 
  comments_count
) VALUES (
  'USER_ID_ANDA',  -- Ganti dengan user_id dari step 1
  'Test post manual dengan foto',
  'https://zmpcueepuevlrkxjiork.supabase.co/storage/v1/object/public/posts/USER_ID_ANDA/nama-file.jpg',  -- Ganti dengan URL foto yang sudah diupload
  'public',
  0,
  0
);

-- 3. Verifikasi
SELECT * FROM posts ORDER BY created_at DESC LIMIT 1;
```

**Jika insert berhasil:**
- Buka home page di aplikasi
- Pull down to refresh
- Post harus muncul! ✅

**Jika insert ERROR:**
- Lihat error message
- Kemungkinan field required tidak lengkap

---

## ✅ VERIFIKASI AKHIR

Setelah jalankan SQL fix di Step 1:

### Cek 1: Policies Sudah Benar
```sql
SELECT policyname, cmd FROM pg_policies WHERE tablename = 'posts';
```

**Expected Output:**
```
policyname                                    | cmd
----------------------------------------------+--------
Enable read access for all users              | SELECT
Enable insert for authenticated users only    | INSERT
Enable update for users based on user_id      | UPDATE
Enable delete for users based on user_id      | DELETE
```

### Cek 2: Data Posts Ada
```sql
SELECT COUNT(*) as total_posts FROM posts;
```

**Expected:** `total_posts` > 0

### Cek 3: Test Select Berhasil
```sql
SELECT * FROM posts ORDER BY created_at DESC LIMIT 1;
```

**Expected:** Ada 1 row dengan data lengkap

---

## 🎯 KEMUNGKINAN BESAR MASALAHNYA:

### Issue 1: RLS Policy SELECT Terlalu Ketat ❌

**Policy Lama (Salah):**
```sql
-- ❌ Ini terlalu ketat!
USING (privacy = 'public' OR user_id = auth.uid())
```

**Masalah:** Jika privacy = 'friends' atau 'only me', post tidak muncul untuk user lain!

**Policy Baru (Benar):**
```sql
-- ✅ Ini lebih longgar
USING (true)  -- Semua user bisa lihat semua posts
```

### Issue 2: Join Profile Gagal

**Jika error:** `could not find the relation "profiles"`

**Solusi:** Pastikan table profiles ada dan ada data

```sql
-- Cek profiles exist
SELECT * FROM profiles LIMIT 1;
```

---

## 🚀 FINAL SOLUTION (Copy-Paste)

**Jalankan SQL lengkap ini untuk fix semua:**

```sql
-- =============================================
-- COMPLETE FIX - POSTS TABLE
-- =============================================

-- 1. Enable RLS (jika belum)
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- 2. Drop all existing policies
DO $$ 
DECLARE
    policy_record RECORD;
BEGIN
    FOR policy_record IN 
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'posts'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON posts', policy_record.policyname);
    END LOOP;
END $$;

-- 3. Create new simple policies
CREATE POLICY "posts_select_policy"
ON posts FOR SELECT
USING (true);

CREATE POLICY "posts_insert_policy"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "posts_update_policy"
ON posts FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "posts_delete_policy"
ON posts FOR DELETE
USING (auth.uid() = user_id);

-- 4. Verify
SELECT 
    'Policies created successfully!' as status,
    COUNT(*) as total_policies 
FROM pg_policies 
WHERE tablename = 'posts';

-- 5. Test query
SELECT 
    p.id,
    p.content,
    p.image_url,
    pr.name as author_name,
    p.created_at
FROM posts p
LEFT JOIN profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC
LIMIT 5;
```

---

## 📱 TEST SETELAH FIX

1. **Restart aplikasi** (full restart!)
2. **Login**
3. **Buka Home Page**
4. **Pull down to refresh**
5. **Posts harus muncul!** ✅

**Jika masih tidak muncul:**
- Screenshot console log
- Screenshot hasil query SQL di Step 2
- Screenshot table posts (beberapa row)

Dengan info ini kita bisa fix tepat sasaran! 🎯
