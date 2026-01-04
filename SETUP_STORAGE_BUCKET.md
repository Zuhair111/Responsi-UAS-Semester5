# 🔧 Setup Supabase Storage Bucket untuk Posts

## ⚠️ Masalah: Post tidak muncul / Foto tidak tampil

Jika foto tidak muncul setelah post, kemungkinan besar **Storage Bucket belum dikonfigurasi**.

---

## 🛠️ Langkah Setup Storage Bucket

### Step 1: Buka Supabase Dashboard
1. Buka browser ke: **https://supabase.com**
2. Login ke akun Anda
3. Pilih project Anda

---

### Step 2: Create Storage Bucket

1. **Klik "Storage"** di sidebar kiri
2. **Klik "Create a new bucket"**
3. **Isi form:**
   ```
   Name: posts
   Public bucket: ✅ CHECKED (PENTING!)
   File size limit: 50MB (atau sesuai kebutuhan)
   Allowed MIME types: (kosongkan untuk allow all)
   ```
4. **Klik "Create bucket"**

**Screenshot Expected:**
```
Storage
├── posts (public) ← Harus ada tanda (public)
```

---

### Step 3: Set Storage Policies

Setelah bucket dibuat, klik bucket **"posts"** → Tab **"Policies"**

#### Policy 1: SELECT (View/Read)
```sql
-- Anyone can view images
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'posts' );
```

**Cara Add:**
1. Klik "New Policy"
2. Pilih "For full customization"
3. Policy name: `Public Access`
4. Allowed operation: **SELECT**
5. Target roles: `public`
6. USING expression:
   ```sql
   bucket_id = 'posts'
   ```
7. Klik "Review" → "Save policy"

---

#### Policy 2: INSERT (Upload)
```sql
-- Authenticated users can upload
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'posts' 
  AND auth.role() = 'authenticated'
);
```

**Cara Add:**
1. Klik "New Policy"
2. Policy name: `Authenticated users can upload`
3. Allowed operation: **INSERT**
4. Target roles: `authenticated`
5. WITH CHECK expression:
   ```sql
   bucket_id = 'posts' AND auth.role() = 'authenticated'
   ```
6. Klik "Review" → "Save policy"

---

#### Policy 3: UPDATE (Update file)
```sql
-- Users can update their own uploads
CREATE POLICY "Users can update own uploads"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'posts' 
  AND auth.uid()::text = (storage.foldername(name))[1]
)
WITH CHECK (
  bucket_id = 'posts' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

---

#### Policy 4: DELETE (Delete file)
```sql
-- Users can delete their own uploads
CREATE POLICY "Users can delete own uploads"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'posts' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

---

### Step 4: Verifikasi Bucket

Setelah setup, cek:

1. **Storage** → **posts** bucket
2. Pastikan ada label **(public)** di samping nama bucket
3. Tab **Policies** → Harus ada 4 policies (SELECT, INSERT, UPDATE, DELETE)

**Checklist:**
- [ ] Bucket `posts` sudah dibuat
- [ ] Bucket bersifat **PUBLIC**
- [ ] Policy SELECT ada (untuk view)
- [ ] Policy INSERT ada (untuk upload)
- [ ] Policy UPDATE ada (opsional)
- [ ] Policy DELETE ada (opsional)

---

## 🧪 Test Upload

### Via Supabase Dashboard:
1. Klik bucket **posts**
2. Klik **"Upload file"**
3. Upload 1 foto test
4. Jika berhasil → Bucket sudah benar! ✅

### Via Aplikasi:
1. Restart aplikasi Flutter
2. Login
3. Create post dengan foto
4. Klik POST
5. Cek console log:

**Log yang Normal:**
```
Uploading image...
Image uploaded: https://zmpcueepuevlrkxjiork.supabase.co/storage/v1/object/public/posts/...
Creating post in database...
Post created successfully
```

**Log Error (Jika bucket belum ada):**
```
Error uploading image: ...
StorageApiError: ... bucket not found
```

---

## 🔍 Debug: Cek Foto di Storage

1. Buka **Supabase Dashboard** → **Storage** → **posts**
2. Harus ada folder dengan nama **user_id**
3. Di dalam folder ada file foto (UUID.jpg)
4. Klik foto → **"Get URL"**
5. Copy URL dan buka di browser
6. Foto harus bisa dilihat ✅

**Struktur Expected:**
```
posts/
└── abc-123-def (user_id)
    ├── uuid-1.jpg
    ├── uuid-2.png
    └── uuid-3.jpg
```

---

## 🔍 Debug: Cek Post di Database

1. Buka **Supabase Dashboard** → **Table Editor** → **posts**
2. Cari row post yang baru dibuat
3. Cek kolom **image_url**
4. Harus ada URL lengkap, contoh:
   ```
   https://zmpcueepuevlrkxjiork.supabase.co/storage/v1/object/public/posts/user-id/uuid.jpg
   ```

**Jika image_url = null:**
- Berarti upload foto gagal
- Cek bucket sudah ada dan public
- Cek policies sudah benar

**Jika image_url ada tapi foto tidak muncul:**
- Copy URL image_url
- Paste di browser
- Jika foto bisa dibuka → Problem di aplikasi
- Jika foto tidak bisa dibuka → Problem di bucket (bukan public atau policies salah)

---

## 🆘 Quick Fix (Manual via SQL Editor)

Jika lebih suka via SQL, jalankan ini di **SQL Editor**:

```sql
-- 1. Check if bucket exists
SELECT * FROM storage.buckets WHERE name = 'posts';

-- 2. If not exists, create it
INSERT INTO storage.buckets (id, name, public)
VALUES ('posts', 'posts', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- 3. Add policies
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'posts' );

CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'posts' 
  AND auth.role() = 'authenticated'
);

CREATE POLICY "Users can update own uploads"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'posts' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete own uploads"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'posts' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## ✅ Verifikasi Final

Setelah setup bucket, test lagi:

### Test 1: Upload via App
```
1. Restart app (Full restart, bukan hot reload)
2. Login
3. Create post + pilih foto
4. POST
5. Lihat console log
```

**Expected Console Log:**
```
Uploading image...
Image uploaded: https://...supabase.co/storage/v1/object/public/posts/...
Creating post in database...
Post created successfully with ID: xxx
```

### Test 2: Check Storage
```
1. Buka Supabase Storage → posts
2. Harus ada folder user_id
3. Di dalam ada file foto
```

### Test 3: Check Database
```
1. Buka Table Editor → posts
2. Row baru ada
3. image_url tidak null
4. image_url bisa dibuka di browser
```

### Test 4: Check Home Page
```
1. Buka home page
2. Pull down to refresh
3. Post muncul dengan foto ✅
```

### Test 5: Check Profile Page
```
1. Buka profile tab
2. Scroll ke "My Posts"
3. Foto muncul di grid ✅
```

---

## 📊 Troubleshooting Matrix

| Gejala | Penyebab | Solusi |
|--------|----------|--------|
| Post ada tapi foto tidak muncul | Bucket tidak public | Set bucket public |
| Error "bucket not found" | Bucket belum dibuat | Create bucket `posts` |
| Upload gagal | Policy INSERT tidak ada | Add policy INSERT |
| Foto tidak bisa dibuka via URL | Policy SELECT tidak ada | Add policy SELECT |
| Post tidak muncul sama sekali | Fetch posts error | Cek console + table posts |
| Loading terus di home | Query error | Cek RLS policies di table posts |

---

## 🎯 Checklist Lengkap

Pastikan semua ini sudah dilakukan:

### Storage Setup
- [ ] Bucket `posts` sudah dibuat
- [ ] Bucket set ke **PUBLIC**
- [ ] Policy SELECT (public access) sudah ada
- [ ] Policy INSERT (authenticated upload) sudah ada

### Database Setup
- [ ] Table `posts` sudah ada
- [ ] RLS enabled di table posts
- [ ] RLS policies (SELECT, INSERT, UPDATE, DELETE) sudah ada

### App Testing
- [ ] App sudah restart (full restart)
- [ ] User sudah login
- [ ] Create post berhasil (ada success notification)
- [ ] Console log tidak ada error
- [ ] Image URL ada di database
- [ ] Image bisa dibuka via browser
- [ ] Post muncul di home
- [ ] Post muncul di profile

---

## 📞 Still Not Working?

Jika masih tidak bisa setelah semua langkah:

1. **Screenshot:**
   - Supabase Storage (bucket list)
   - Supabase Storage Policies
   - Console log saat create post
   - Table posts (row data)

2. **Check:**
   - Versi supabase_flutter di pubspec.yaml
   - URL Supabase di supabase_service.dart benar
   - Anon Key Supabase benar
   - Internet connection

3. **Try:**
   - Logout dan login lagi
   - Clear app data
   - Restart device
   - Test di device lain

---

## 🎉 Setelah Setup Berhasil

Anda akan bisa:
- ✅ Upload foto dengan lancar
- ✅ Foto tersimpan di Storage
- ✅ Post muncul di home dengan foto
- ✅ Post muncul di profile dengan foto
- ✅ Foto bisa dibuka langsung via URL

**Silakan setup sekarang dan test lagi!** 🚀
