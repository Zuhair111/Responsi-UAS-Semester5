# Story Feature Implementation

## Fitur yang Telah Dibuat

### 1. Model Story
**File:** `lib/models/story_model.dart`

Model untuk merepresentasikan data story dengan fitur:
- User information (username, avatar)
- Image URL
- Created & expired timestamps
- Helper methods (isExpired, timeAgo)

### 2. Story Service
**File:** `lib/services/story_service.dart`

Service untuk handle story operations:
- ✅ **Upload Story Image** - Upload gambar ke Supabase Storage
- ✅ **Create Story** - Buat story baru dengan expiry 24 jam
- ✅ **Get Active Stories** - Ambil semua story yang belum expired
- ✅ **Get User Stories** - Ambil story dari user tertentu
- ✅ **Get My Stories** - Ambil story milik user saat ini
- ✅ **Delete Story** - Hapus story
- ✅ **Group Stories By User** - Group stories berdasarkan user

### 3. Create Story Page
**File:** `lib/pages/create_story_page.dart`

Halaman untuk membuat story baru dengan fitur:
- ✅ Pilih gambar dari gallery atau camera
- ✅ Preview gambar sebelum upload
- ✅ Upload progress indicator
- ✅ Edit/change gambar sebelum post

### 4. Story View Page (Updated)
**File:** `lib/pages/story_view_page.dart`

Halaman untuk melihat story dengan fitur baru:
- ✅ **Kirim pesan ke chat** - User bisa mengetik pesan dan akan dikirim langsung ke chat dengan pemilik story
- ✅ Integrasi dengan ChatService
- ✅ Auto create conversation jika belum ada
- ✅ Loading indicator saat kirim pesan
- ✅ Notifikasi sukses/error

**Cara Kerja:**
1. User mengetik pesan di text field
2. Klik tombol send
3. Sistem otomatis membuat/mengambil conversation dengan pemilik story
4. Pesan dikirim ke chat
5. User menerima notifikasi bahwa pesan terkirim

### 5. Home Page (Updated)
**File:** `lib/pages/home_page.dart`

Update untuk menampilkan real stories dari database:
- ✅ Fetch active stories dari database
- ✅ Tampilkan "Add Story" atau "Your Story" button
- ✅ Group stories by user dengan badge jumlah
- ✅ Gradient ring untuk story yang belum dilihat
- ✅ Klik "Add Story" untuk create new story
- ✅ Klik "Your Story" untuk view my stories
- ✅ Auto refresh stories setelah upload

### 6. Database Migration
**File:** `supabase_migration_stories.sql`

SQL untuk membuat tabel stories:
```sql
- Table: stories
  - id (UUID, Primary Key)
  - user_id (UUID, Foreign Key to auth.users)
  - image_url (TEXT)
  - created_at (TIMESTAMP)
  - expires_at (TIMESTAMP)
  
- Indexes untuk performance
- Row Level Security policies
- Auto cleanup function untuk expired stories
```

## Cara Setup

### 1. Jalankan SQL Migration di Supabase

1. Login ke Supabase Dashboard
2. Pilih project Anda
3. Buka SQL Editor
4. Copy paste isi file `supabase_migration_stories.sql`
5. Run query

### 2. Setup Storage Bucket (Jika Belum)

Stories menggunakan bucket `avatars` yang sudah ada. Pastikan bucket sudah di-setup dengan:
- Public access enabled
- Allowed MIME types: image/*

### 3. Dependencies yang Dibutuhkan

Pastikan dependencies berikut ada di `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^latest_version
  image_picker: ^latest_version
```

Run:
```bash
flutter pub get
```

### 4. Test Feature

1. **Upload Story:**
   - Klik "Add Story" di home page
   - Pilih gambar dari gallery/camera
   - Klik "Share" untuk upload
   
2. **View Story:**
   - Klik pada story avatar
   - Story akan ditampilkan dengan auto-progress
   - Tap kiri/kanan untuk navigate
   
3. **Send Message dari Story:**
   - Saat melihat story, ketik pesan di text field
   - Klik tombol send
   - Pesan akan terkirim ke chat dengan pemilik story
   - Cek di Chat List untuk melihat conversation

## Struktur File Baru

```
lib/
├── models/
│   └── story_model.dart           [NEW]
├── services/
│   └── story_service.dart         [NEW]
└── pages/
    ├── create_story_page.dart     [NEW]
    ├── story_view_page.dart       [UPDATED]
    └── home_page.dart             [UPDATED]

supabase_migration_stories.sql    [NEW]
```

## Fitur Utama

### 1. Upload Story
- User dapat upload story dengan gambar
- Story otomatis expired dalam 24 jam
- Mendukung multiple stories per user

### 2. View Stories
- Auto-play dengan progress indicator
- Tap navigation (kiri/kanan)
- Long press untuk pause
- Swipe untuk skip

### 3. Comment/Message di Story
- **User dapat mengirim komentar langsung ke chat pemilik story**
- Auto create conversation jika belum ada
- Message langsung masuk ke chat inbox
- Tidak perlu navigasi manual ke chat

## Flow Pengiriman Pesan

```
User melihat story → 
Ketik komentar → 
Klik send → 
System get/create conversation → 
Kirim message ke database → 
Message muncul di ChatListPage
```

## Security

- Row Level Security enabled untuk stories table
- Users hanya bisa create/delete story mereka sendiri
- Semua user bisa view active stories
- Images di-upload ke secure Supabase Storage

## Tips

1. Story akan otomatis hilang setelah 24 jam
2. User bisa upload multiple stories
3. Komentar di story langsung jadi chat message
4. Pastikan user sudah login sebelum create story
5. Check internet connection untuk upload images

## Troubleshooting

**Story tidak muncul?**
- Check apakah SQL migration sudah dijalankan
- Check apakah story belum expired
- Check console untuk error messages

**Upload gagal?**
- Check internet connection
- Check storage bucket permissions
- Check file size (sebaiknya < 5MB)

**Pesan tidak terkirim?**
- Check apakah messages table sudah ada
- Check conversation function sudah ada
- Check user permissions di database

## Next Steps (Optional)

Fitur tambahan yang bisa ditambahkan:
- View receipts (siapa saja yang sudah lihat story)
- Story reactions (emoji reactions)
- Story replies dengan preview
- Story deletion before 24h
- Story archive
- Story highlights
