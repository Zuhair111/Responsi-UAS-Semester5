# Troubleshooting: Failed to Load Profile

## Masalah yang Sering Terjadi

### ❌ Error: "Failed to load profile"

Ini terjadi ketika aplikasi tidak bisa mengambil data profil dari Supabase. Ada beberapa penyebab:

---

## ✅ Solusi 1: Pastikan User Sudah Login

**Gejala:** Error message "Please login first"

**Cara Fix:**
1. Pastikan user sudah login
2. Cek di console: `getCurrentUserProfile: No user logged in`
3. Login terlebih dahulu sebelum membuka profile page

---

## ✅ Solusi 2: Jalankan Migration SQL

**Gejala:** Profile data not found meskipun sudah login

**Cara Fix:**

### A. Jika Database Baru (Belum Ada Tabel)
1. Buka Supabase Dashboard → SQL Editor
2. Copy semua isi dari file `supabase_setup.sql`
3. Paste dan Run
4. Restart aplikasi dan login lagi

### B. Jika Database Sudah Ada (Tabel profiles sudah ada)
1. Buka Supabase Dashboard → SQL Editor
2. Copy semua isi dari file `supabase_migration_add_username.sql`
3. Paste dan Run
4. Cek apakah field `username` sudah ada di tabel `profiles`

**Verifikasi di Supabase:**
1. Buka Table Editor → profiles
2. Pastikan kolom berikut ada:
   - ✅ id
   - ✅ username (BARU - harus ada!)
   - ✅ name
   - ✅ email
   - ✅ avatar_url
   - ✅ bio
   - ✅ created_at
   - ✅ updated_at

---

## ✅ Solusi 3: Cek Data Profile di Database

**Jika migration sudah dijalankan tapi tetap error:**

1. Buka Supabase → Table Editor → profiles
2. Cari row dengan `id` sama dengan user ID Anda
3. **Jika tidak ada row:**
   - Profile belum dibuat saat signup
   - Solusi: Logout, lalu signup lagi

4. **Jika ada row tapi field `username` null:**
   ```sql
   -- Jalankan query ini di SQL Editor
   UPDATE profiles 
   SET username = SPLIT_PART(email, '@', 1)
   WHERE username IS NULL;
   ```

---

## ✅ Solusi 4: Periksa Console Logs

Buka Debug Console dan cari pesan error:

### Log Normal (Berhasil):
```
Loading profile for user: xxx-xxx-xxx
Fetching profile for user: xxx-xxx-xxx
Profile fetched successfully: {id: xxx, username: johndoe, name: John...}
Profile loaded: {id: xxx, username: johndoe...}
```

### Log Error (Gagal):
```
getCurrentUserProfile: No user logged in
// Solusi: Login terlebih dahulu
```

```
Error fetching profile: ...
// Solusi: Cek database dan jalankan migration
```

---

## ✅ Solusi 5: Trigger Tidak Aktif

Jika user baru signup tapi profile tidak dibuat otomatis:

1. Cek trigger di Supabase SQL Editor:
```sql
-- Cek apakah trigger ada
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
```

2. Jika tidak ada, jalankan ulang bagian trigger dari `supabase_setup.sql`:
```sql
-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

3. Test dengan signup user baru

---

## ✅ Solusi 6: Manual Create Profile

Jika semua cara di atas gagal, buat profile secara manual:

```sql
-- Ganti dengan data Anda
INSERT INTO profiles (id, username, name, email, bio, avatar_url)
VALUES (
  'USER_ID_DARI_AUTH_USERS', -- Ambil dari auth.users
  'username_anda',            -- Username tanpa @
  'Nama Lengkap',
  'email@example.com',
  'Bio anda',
  NULL                        -- atau URL foto profil
);
```

**Cara dapat USER_ID:**
```sql
-- Lihat semua user
SELECT id, email FROM auth.users;
```

---

## 🔍 Checklist Debug

- [ ] User sudah login? (Cek `_authService.currentUser != null`)
- [ ] Tabel `profiles` sudah ada?
- [ ] Field `username` sudah ditambahkan ke tabel?
- [ ] Migration SQL sudah dijalankan?
- [ ] Ada data profile untuk user yang login?
- [ ] Field `username` tidak null?
- [ ] Trigger `on_auth_user_created` sudah aktif?
- [ ] Console log menunjukkan error apa?

---

## 📞 Langkah-langkah Debug Lengkap

1. **Cek Login Status**
   ```dart
   print('User logged in: ${SupabaseService.isLoggedIn}');
   print('Current user: ${SupabaseService.currentUser?.id}');
   ```

2. **Cek Database**
   - Buka Supabase Dashboard
   - Table Editor → profiles
   - Cari data dengan ID user yang login

3. **Test Query Manual**
   ```sql
   SELECT * FROM profiles WHERE id = 'USER_ID_ANDA';
   ```

4. **Jalankan Migration**
   - Copy `supabase_migration_add_username.sql`
   - Paste di SQL Editor
   - Run

5. **Restart App**
   - Hot restart (Ctrl+Shift+F5)
   - Atau full restart

6. **Cek Console**
   - Lihat log "Loading profile..."
   - Lihat log "Profile loaded..."
   - Cek apakah ada error

---

## 💡 Tips Pencegahan

1. **Selalu jalankan migration SQL sebelum testing**
2. **Cek console log untuk debugging**
3. **Verifikasi data di Supabase Dashboard**
4. **Test dengan user baru setelah setup**
5. **Jangan skip error di console - baca pesannya!**

---

## 🆘 Masih Error?

Jika masih mengalami error setelah semua solusi di atas:

1. Screenshot error message di console
2. Screenshot struktur tabel `profiles` di Supabase
3. Screenshot data di tabel `profiles`
4. Bagikan untuk analisis lebih lanjut

---

## 📋 Verifikasi Akhir

Setelah fix, coba:
1. ✅ Logout
2. ✅ Login lagi
3. ✅ Buka Profile page
4. ✅ Harus tampil: @username, nama, bio
5. ✅ Bisa edit profile
6. ✅ Data tersimpan ke database
