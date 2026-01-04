# 🔍 DEBUG GUIDE: Post Tidak Muncul

## ⚠️ Jika bucket sudah dibuat tapi tetap tidak bisa

Mari kita debug step-by-step untuk menemukan masalah sebenarnya.

---

## 🧪 STEP 1: Cek Console Log Detail

Saat Anda create post, buka **Debug Console** dan cari log ini:

### ✅ Log Normal (Berhasil):
```
=== Creating post ===
User logged in: true
Current user: abc-123-def
Uploading image...
Image uploaded: https://zmpcueepuevlrkxjiork.supabase.co/storage/v1/object/public/posts/abc-123-def/uuid.jpg
Creating post in database...
Post created successfully with ID: xyz-456-789
```

### ❌ Log Error - Bucket Issue:
```
Error uploading image: StorageApiError: Bucket not found
```
**Solusi:** Bucket belum dibuat atau nama salah

### ❌ Log Error - Permission Issue:
```
Error uploading image: StorageApiError: new row violates row-level security policy
```
**Solusi:** Policy INSERT belum ada atau salah

### ❌ Log Error - Database Issue:
```
Error creating post: PostgrestException: new row violates row-level security
```
**Solusi:** RLS policy di table posts belum ada

---

## 🧪 STEP 2: Test Upload Manual di Supabase

1. **Buka Supabase Dashboard** → **Storage** → **posts**
2. **Klik "Upload file"**
3. **Upload 1 foto test**

**Jika gagal upload:**
- Bucket belum public
- Policy tidak ada

**Jika berhasil upload:**
- Bucket sudah OK ✅
- Masalah ada di aplikasi

---

## 🧪 STEP 3: Verifikasi Table Posts

### Cek RLS Policies di Table Posts

1. **Buka Supabase** → **Table Editor** → **posts**
2. **Klik icon RLS** (shield icon)
3. **Pastikan ada policies:**
   - SELECT (view posts)
   - INSERT (create posts)
   - UPDATE (edit posts)
   - DELETE (delete posts)

### Cek Data di Table

1. **Table Editor** → **posts**
2. **Lihat semua rows**
3. **Cari post yang baru Anda buat**

**Jika row ada:**
- Cek kolom `image_url` → Harus ada URL
- Cek kolom `user_id` → Harus sesuai dengan user yang login
- Copy URL image_url → Paste di browser → Lihat apakah foto bisa dibuka

**Jika row tidak ada:**
- Post gagal tersimpan
- Cek console log untuk error
- Kemungkinan RLS policy INSERT di table posts tidak ada

---

## 🧪 STEP 4: Debug di Aplikasi

### Tambahkan Debug Print

Buka file: `lib/services/post_service.dart`

Cari method `uploadImage` dan pastikan ada print statement:

```dart
Future<String?> uploadImage({
  required Uint8List imageBytes,
  required String fileName,
}) async {
  try {
    final user = _client.auth.currentUser;
    if (user == null) {
      print('❌ ERROR: User not logged in');
      return null;
    }

    print('✅ User logged in: ${user.id}');
    print('📁 Uploading to bucket: posts');
    print('📄 File name: $fileName');

    final fileExt = fileName.split('.').last;
    final uniqueFileName = '${_uuid.v4()}.$fileExt';
    final filePath = '${user.id}/$uniqueFileName';

    print('📂 File path: $filePath');

    await _client.storage.from('posts').uploadBinary(
      filePath,
      imageBytes,
      fileOptions: FileOptions(
        contentType: 'image/$fileExt',
        upsert: true,
      ),
    );

    print('✅ Upload successful');

    final imageUrl = _client.storage.from('posts').getPublicUrl(filePath);
    print('🔗 Image URL: $imageUrl');
    
    return imageUrl;
  } catch (e) {
    print('❌ Error uploading image: $e');
    print('❌ Error type: ${e.runtimeType}');
    return null;
  }
}
```

### Restart & Test

1. **Hot restart** aplikasi (Ctrl + Shift + F5)
2. **Login**
3. **Create post dengan foto**
4. **Lihat console log** → Cari emoji ✅ dan ❌

---

## 🧪 STEP 5: Verifikasi Posts Muncul di Home

### Cek method _loadPosts di home_page.dart

Pastikan ada log:

```dart
Future<void> _loadPosts() async {
  print('🔄 Loading posts from database...');
  setState(() => _isLoadingPosts = true);
  try {
    final posts = await _postService.getPosts();
    print('✅ Posts loaded: ${posts.length} posts');
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoadingPosts = false;
      });
    }
  } catch (e) {
    print('❌ Error loading posts: $e');
    if (mounted) {
      setState(() => _isLoadingPosts = false);
    }
  }
}
```

---

## 🧪 STEP 6: Cek getPosts() Method

Buka `lib/services/post_service.dart`, cari method `getPosts`:

```dart
Future<List<PostModel>> getPosts({int limit = 20, int offset = 0}) async {
  try {
    print('📥 Fetching posts from database...');
    final response = await _client
        .from('posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    print('✅ Database response: ${response.length} posts');
    
    return (response as List).map((post) {
      final profile = post['profiles'];
      return PostModel.fromJson(post, profile);
    }).toList();
  } catch (e) {
    print('❌ Error getting posts: $e');
    print('❌ Error type: ${e.runtimeType}');
    return [];
  }
}
```

---

## 🆘 COMMON ISSUES & FIXES

### Issue 1: "Row violates row-level security policy"

**Di Table Posts:**
```sql
-- Jalankan di SQL Editor
-- Policy untuk SELECT
CREATE POLICY "Allow public to read posts"
ON posts FOR SELECT
USING (privacy = 'public' OR user_id = auth.uid());

-- Policy untuk INSERT
CREATE POLICY "Allow authenticated users to create posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

---

### Issue 2: Posts ada di database tapi tidak muncul di home

**Cek Query:**
1. Buka **SQL Editor** di Supabase
2. Jalankan query:
```sql
SELECT p.*, pr.name, pr.username, pr.avatar_url
FROM posts p
LEFT JOIN profiles pr ON p.user_id = pr.id
ORDER BY p.created_at DESC
LIMIT 10;
```

**Jika query error:**
- Table profiles tidak ada join relationship
- Field profiles tidak ada

**Jika query berhasil:**
- Data ada di database ✅
- Masalah di aplikasi (fetch atau display)

---

### Issue 3: Image URL null di database

**Berarti upload foto gagal**

1. Cek console log saat create post
2. Lihat error "Error uploading image"
3. Kemungkinan:
   - Bucket tidak ada
   - Policy INSERT di storage tidak ada
   - File terlalu besar
   - Format file tidak supported

---

### Issue 4: Posts muncul tapi foto tidak tampil

**Cek Image URL:**
1. Copy URL dari database
2. Paste di browser
3. Jika foto tidak bisa dibuka → Policy SELECT di storage tidak ada

**Fix:**
```sql
-- Policy SELECT di storage.objects
CREATE POLICY "Public Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'posts' );
```

---

## 🔧 MANUAL FIX: Create Post Test via SQL

Jika aplikasi tidak bisa, test manual via SQL:

```sql
-- 1. Dapatkan user_id Anda
SELECT id, email FROM auth.users;

-- 2. Insert post manual
INSERT INTO posts (user_id, content, image_url, privacy, likes_count, comments_count)
VALUES (
  'USER_ID_ANDA', -- Ganti dengan user_id dari step 1
  'Test post manual',
  'https://picsum.photos/400/600', -- Test image URL
  'public',
  0,
  0
);

-- 3. Cek apakah post muncul
SELECT * FROM posts ORDER BY created_at DESC LIMIT 5;
```

**Jika insert berhasil:**
- Database OK ✅
- Buka home page di aplikasi
- Jika post muncul → Masalah di create post page
- Jika post tidak muncul → Masalah di fetch posts

---

## 🎯 QUICK CHECKLIST

Centang semua yang sudah dicek:

### Storage Setup
- [ ] Bucket `posts` ada
- [ ] Bucket bersifat PUBLIC (ada label "public")
- [ ] Policy SELECT ada: `CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'posts');`
- [ ] Policy INSERT ada: `CREATE POLICY "Authenticated Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'posts' AND auth.role() = 'authenticated');`
- [ ] Test upload manual berhasil

### Database Setup
- [ ] Table `posts` ada
- [ ] Table `profiles` ada
- [ ] RLS enabled di table posts
- [ ] Policy SELECT di posts: `CREATE POLICY "Allow public to read" ON posts FOR SELECT USING (privacy = 'public' OR user_id = auth.uid());`
- [ ] Policy INSERT di posts: `CREATE POLICY "Allow auth to insert" ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);`

### App Debug
- [ ] User sudah login (cek console log)
- [ ] Console log tidak ada error saat upload
- [ ] Console log show "Upload successful"
- [ ] Console log show "Post created successfully"
- [ ] Image URL tidak null di database
- [ ] Image URL bisa dibuka di browser
- [ ] Console log tidak ada error saat fetch posts
- [ ] Console log show "Posts loaded: X posts"

### App Display
- [ ] Home page tidak stuck di loading
- [ ] Home page ada "No posts" atau posts tampil
- [ ] Profile page load posts user
- [ ] Profile page tidak stuck di loading

---

## 📱 TEST DENGAN CARA INI:

### Test 1: Create Post Text Only (No Photo)

```
1. Create post
2. Isi caption: "Test post tanpa foto"
3. JANGAN pilih foto
4. POST
```

**Jika berhasil:**
- Post muncul di home dengan text saja
- Berarti database OK ✅
- Masalah di upload foto

**Jika gagal:**
- Masalah di database
- Cek RLS policies di table posts

---

### Test 2: Check Supabase Logs

1. **Supabase Dashboard** → **Logs** (sidebar)
2. **API Logs** → Lihat request terakhir
3. Cari error atau status code

**Status Code:**
- 200/201 = Success ✅
- 400 = Bad request (data salah)
- 401 = Unauthorized (auth issue)
- 403 = Forbidden (RLS policy issue)
- 500 = Server error

---

## 🆘 ULTIMATE DEBUG COMMAND

Jalankan SQL ini untuk cek semua setup:

```sql
-- 1. Cek bucket exists
SELECT * FROM storage.buckets WHERE name = 'posts';
-- Expected: 1 row, public = true

-- 2. Cek storage policies
SELECT * FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects' 
AND policyname LIKE '%posts%';
-- Expected: minimal 2 policies (SELECT, INSERT)

-- 3. Cek table posts policies
SELECT * FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'posts';
-- Expected: minimal 2 policies (SELECT, INSERT)

-- 4. Cek posts data
SELECT id, user_id, content, image_url, created_at 
FROM posts 
ORDER BY created_at DESC 
LIMIT 5;
-- Expected: Ada data post yang baru dibuat

-- 5. Cek profiles data
SELECT id, username, name, email 
FROM profiles 
ORDER BY created_at DESC 
LIMIT 5;
-- Expected: Ada profile user yang login
```

---

## 📞 Kirim Info Ini untuk Debug Lebih Lanjut:

Jika masih tidak bisa, screenshot/copy ini:

1. **Console log** lengkap saat create post
2. **Console log** saat load home page
3. **Screenshot** Supabase Storage (bucket list)
4. **Screenshot** Supabase Storage Policies (policy list)
5. **Screenshot** Table posts (beberapa row data)
6. **Result** dari Ultimate Debug Command di atas
7. **Network tab** di browser DevTools (jika web)

Dengan info ini kita bisa tahu persis masalahnya ada dimana! 🎯
