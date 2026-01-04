# Setup Reels Feature

Fitur Reels memungkinkan user untuk membuat dan menonton video pendek (maksimal 10 detik) dengan auto compression saat upload.

## Database Setup

1. Jalankan migration SQL untuk membuat tabel reels:
   ```sql
   -- Jalankan file: supabase_migration_reels.sql
   ```

2. Migration akan membuat tabel-tabel berikut:
   - `reels` - Tabel utama untuk menyimpan data reels
   - `reel_likes` - Tabel untuk menyimpan likes pada reels
   - `reel_views` - Tabel untuk menyimpan views pada reels

## Storage Setup

1. Buat bucket `videos` di Supabase Storage:
   - Masuk ke Supabase Dashboard
   - Pilih Storage
   - Buat bucket baru dengan nama `videos`
   - Set sebagai public bucket

2. Buat folder structure di bucket `videos`:
   ```
   videos/
   ├── reels/           (untuk video reels)
   └── thumbnails/      (untuk thumbnail reels)
   ```

## Features Included

### 1. Create Reels
- **Location**: Create Post Page → "Create Reel" button
- **Functionality**:
  - Pick video dari gallery (maksimal 10 detik)
  - Auto validation durasi video
  - Auto compress video sebelum upload
  - Generate thumbnail otomatis
  - Add caption (optional)
  - Preview video sebelum upload

### 2. View Reels
- **Location**: Home Page → Reels tab
- **Functionality**:
  - Swipe vertical untuk next/previous reel
  - Auto play video saat di-view
  - Like/unlike reels
  - View counter otomatis
  - Tap to play/pause

### 3. Create Reel Button in Create Post
- Mengganti "Live Video" dengan "Create Reel"
- Direct navigation ke create reel page
- Auto return ke previous page setelah upload

## How to Use

### Membuat Reel:
1. Buka halaman Create Post
2. Klik tombol "Create Reel"
3. Pilih video dari gallery (video > 10 detik akan auto trim)
4. Tunggu video di-compress dan trim jika perlu
5. (Optional) Tambahkan caption
6. Klik "POST" untuk upload

### Menonton Reels:
1. Buka halaman Reels dari navigation
2. Swipe vertical untuk next/previous reel
3. Tap video untuk play/pause
4. Double tap atau klik icon love untuk like

## Video Compression

Video akan otomatis di-process dengan settings:
- **Auto Trim**: Video > 10 detik akan dipotong ke 10 detik pertama
- **Quality**: Medium Quality
- **Audio**: Included
- **Original file**: Tidak dihapus
- **Thumbnail**: Auto generated dari video

## Dependencies

Package yang digunakan:
```yaml
dependencies:
  video_player: ^2.9.1        # Untuk playback video
  video_compress: ^3.1.2      # Untuk compress video
  image_picker: ^1.0.4        # Untuk pick video dari gallery
  path_provider: ^2.1.1       # Untuk path management
```

## Technical Details

### Video Validation (video lebih panjang akan auto trim)
- Format: MP4, MOV, AVI (semua format yang didukung image_picker)
- Size: Akan di-compress otomatis

### Video Compression Process
1. User memilih video
2. Check durasi video
3. **Trim ke 10 detik pertama jika > 10 detik**
4. Compress video dengan VideoCompress
5. Generate thumbnail
6. Upload ke Supabase Storage
7. Upload ke Supabase Storage
6. Simpan metadata ke database

### Database Structure

#### Reels Table
```sql
- id (UUID)
- user_id (UUID)
- video_url (TEXT)
- thumbnail_url (TEXT)
- caption (TEXT)
- duration (INTEGER) - Max 10 seconds
- likes_count (INTEGER)
- comments_count (INTEGER)
- views_count (INTEGER)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### Reel Likes Table
```sql
- id (UUID)
- reel_id (UUID)
- user_id (UUID)
- created_at (TIMESTAMP)
```

#### Reel Views Table
```sql
- id (UUID)
- reel_id (UUID)
- user_id (UUID)
- created_at (TIMESTAMP)
```

## Files Modified/Created

### New Files:
1. `lib/models/reel_model.dart` - Model untuk reels
2. `lib/services/reel_service.dart` - Service untuk handle reels operations
3. `lib/pages/create_reel_page.dart` - Halaman create reel
4. `supabase_migration_reels.sql` - Database migration

### Modified Files:
1. `lib/pages/create_post_page.dart` - Tambah button "Create Reel"
2. `lib/pages/reels_page.dart` - Update untuk load reels dari database
3. `lib/widgets/reel_item.dart` - Update untuk handle real data
4. `pubspec.yaml` - Tambah dependencies

## Notes

- **Video > 10 detik akan otomatis dipotong ke 10 detik pertama**udah dibuat dan set sebagai public
- Video akan di-compress otomatis untuk menghemat bandwidth dan storage
- Reels hanya support video maksimal 10 detik
- Thumbnail akan di-generate otomatis dari frame pertama video
- Views dihitung sekali per user per reel
- Likes bisa di-toggle (like/unlike)
