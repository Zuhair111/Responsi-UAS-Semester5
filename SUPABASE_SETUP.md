# Setup Supabase untuk Aplikasi Flutter

## Langkah 1: Buat Project Supabase

1. Kunjungi [https://supabase.com](https://supabase.com)
2. Buat akun atau login
3. Klik "New Project"
4. Isi nama project dan password database
5. Pilih region terdekat
6. Tunggu project selesai dibuat

## Langkah 2: Setup Database

1. Buka project Supabase Anda
2. Klik **SQL Editor** di sidebar kiri
3. Copy semua isi dari file `supabase_setup.sql` di project ini
4. Paste ke SQL Editor
5. Klik **Run** untuk menjalankan semua SQL

## Langkah 3: Setup Storage

1. Klik **Storage** di sidebar kiri
2. Klik **New bucket**
3. Buat bucket dengan nama: `posts`
4. **PENTING**: Centang "Public bucket"
5. Klik **Create bucket**

### Tambah Storage Policies:

1. Klik bucket `posts`
2. Klik tab **Policies**
3. Tambahkan policies berikut:

**Policy 1 - View Images (SELECT)**
- Name: `Anyone can view images`
- Policy: `true`

**Policy 2 - Upload Images (INSERT)**
- Name: `Authenticated users can upload`
- Target roles: `authenticated`
- Policy: `true`

**Policy 3 - Delete Images (DELETE)**
- Name: `Users can delete own images`
- Target roles: `authenticated`  
- Policy: `(bucket_id = 'posts') AND (auth.uid()::text = (storage.foldername(name))[1])`

## Langkah 4: Dapatkan API Keys

1. Klik **Settings** (ikon gear) di sidebar
2. Klik **API** di submenu
3. Copy:
   - **Project URL** → ini adalah `supabaseUrl`
   - **anon public** key → ini adalah `supabaseAnonKey`

## Langkah 5: Update Kode Flutter

Buka file `lib/services/supabase_service.dart` dan ganti:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Dengan nilai yang sudah Anda copy dari Supabase Dashboard.

**Contoh:**
```dart
static const String supabaseUrl = 'https://abcdefghijklmnop.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

## Langkah 6: Jalankan Aplikasi

```bash
flutter pub get
flutter run
```

## Fitur yang Tersedia

### Autentikasi
- ✅ Register (buat akun baru)
- ✅ Login (masuk dengan email & password)
- ✅ Logout
- ✅ Auto-create profile saat register

### Post dengan Gambar
- ✅ Buat post baru dengan teks
- ✅ Upload gambar ke Supabase Storage
- ✅ Tampilkan feed posts dari database
- ✅ Like/unlike post
- ✅ Hapus post sendiri

### Database Tables
- `profiles` - Data profil user
- `posts` - Data postingan
- `likes` - Data likes
- `comments` - Data komentar

## Troubleshooting

### Error: "Invalid API Key"
- Pastikan Anda sudah mengganti `supabaseUrl` dan `supabaseAnonKey` dengan nilai yang benar

### Error: "User not found"
- Pastikan user sudah terdaftar dan terverifikasi
- Cek di Supabase Dashboard → Authentication → Users

### Gambar tidak muncul
- Pastikan bucket `posts` sudah dibuat dan bersifat public
- Pastikan policies storage sudah ditambahkan

### Error RLS (Row Level Security)
- Pastikan semua SQL dari `supabase_setup.sql` sudah dijalankan
- Cek di Database → Tables → (pilih table) → Policies
