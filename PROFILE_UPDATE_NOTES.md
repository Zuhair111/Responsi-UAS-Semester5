# Update Profil dengan Supabase Integration

## Perubahan yang Dilakukan

### 1. Database Schema (Supabase)
- **Tambahan field `username`** di tabel `profiles`
  - Username bersifat UNIQUE dan tidak bisa diubah
  - Username otomatis diambil dari email (bagian sebelum @)
  - Ditampilkan dengan format @username

### 2. Profile Page (`profile_page.dart`)
**Fitur Baru:**
- ✅ Mengambil data user dari Supabase secara real-time
- ✅ Menampilkan username dengan @ (tidak bisa diubah)
- ✅ Menampilkan nama user (bisa diubah di edit profile)
- ✅ Menampilkan bio dari database
- ✅ Menampilkan jumlah post user yang sebenarnya
- ✅ Menampilkan foto profil dari database
- ✅ Loading state saat mengambil data
- ✅ Error handling dengan retry button
- ✅ Refresh data setelah edit profile

### 3. Edit Profile Page (`edit_profile_page.dart`)
**Fitur Baru:**
- ✅ Username ditampilkan tapi tidak bisa diedit (read-only)
- ✅ Nama bisa diedit dan disimpan ke database
- ✅ Bio bisa diedit dan disimpan ke database
- ✅ Loading state saat menyimpan data
- ✅ Notifikasi sukses/error saat menyimpan
- ✅ Kembali ke profile page dengan refresh data

## Cara Setup Database

### Jika Database Baru (Belum Ada Tabel)
Jalankan file: `supabase_setup.sql` di Supabase SQL Editor

### Jika Database Sudah Ada
Jalankan file: `supabase_migration_add_username.sql` di Supabase SQL Editor

## Struktur Data Profile

```dart
{
  'id': 'uuid',
  'username': 'johndoe',        // Tidak bisa diubah
  'name': 'John Doe',          // Bisa diubah
  'email': 'johndoe@email.com',
  'avatar_url': 'https://...',
  'bio': 'Bio text...',        // Bisa diubah
  'created_at': 'timestamp',
  'updated_at': 'timestamp'
}
```

## Flow Aplikasi

1. **User Login** → Auth Service
2. **Load Profile** → Ambil data dari tabel `profiles` berdasarkan user ID
3. **Display Profile** → Tampilkan @username (permanent) dan nama (editable)
4. **Edit Profile** → Update hanya field `name` dan `bio`
5. **Save Changes** → Update ke Supabase dan refresh profile page

## Perbedaan Username vs Name

| Field | Format | Bisa Diubah? | Ditampilkan |
|-------|--------|--------------|-------------|
| **username** | @username | ❌ Tidak | Profile page |
| **name** | Nama Lengkap | ✅ Ya | Profile page & Edit |

## Testing

1. Login dengan akun yang sudah ada
2. Buka profile page
3. Cek apakah username tampil dengan format @username
4. Cek apakah nama dan bio tampil dari database
5. Klik tombol edit
6. Coba ubah nama dan bio
7. Save dan cek apakah data berhasil diupdate
8. Cek bahwa username tetap tidak berubah

## Error Handling

- Loading spinner saat fetch data
- Error message jika gagal load profile
- Retry button untuk reload data
- Success/error notification saat save
- Fallback icon jika foto profil tidak ada

## File yang Dimodifikasi

1. ✅ `lib/pages/profile_page.dart` - Integrasi Supabase
2. ✅ `lib/pages/edit_profile_page.dart` - Edit profile dengan Supabase
3. ✅ `supabase_setup.sql` - Tambah field username
4. ✅ `supabase_migration_add_username.sql` - Migration untuk DB existing

## Dependencies yang Digunakan

```yaml
dependencies:
  supabase_flutter: ^latest
  image_picker: ^latest
  uuid: ^latest
```
