# Quick Guide: Reels Feature

## ✨ Fitur Baru: Reels dengan Auto Compress Video

Reels adalah fitur video pendek (maksimal 10 detik) dengan auto compression saat upload.

### 🚀 Quick Setup

1. **Database Setup**
   ```bash
   # Jalankan migration SQL di Supabase SQL Editor
   # File: supabase_migration_reels.sql
   ```

2. **Storage Setup**
   - Buat bucket `videos` di Supabase Storage (public)
   - Folder akan dibuat otomatis saat upload

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

### 📱 Cara Menggunakan

#### Membuat Reel:
1. **Dari Create Post Page**
   - Klik tombol "Create Reel" (mengganti Live Video)
   - Pilih video dari gallery (akan auto trim ke 10 detik jika lebih panjang)
   - Video akan otomatis di-compress dan trim jika perlu
   - Tambahkan caption (opsional)
   - Klik "POST"

2. **Video akan otomatis:**
   - ✅ Di-trim ke 10 detik pertama jika lebih panjang
   - ✅ Di-compress untuk menghemat storage
   - ✅ Generate thumbnail
   - ✅ Upload ke Supabase

#### Menonton Reels:
1. Buka halaman Reels dari navigation
2. Swipe vertical untuk next/previous
3. Tap untuk play/pause
4. Double tap atau klik ❤️ untuk like

### 🎯 Features

- ✅ **Auto Trim**: Video > 10 detik otomatis dipotong ke 10 detik pertama
- ✅ **Auto Compress**: Video otomatis di-compress sebelum upload
- ✅ **Max 10 Second**: Support video hingga 10 detik
- ✅ **Auto Thumbnail**: Generate thumbnail otomatis
- ✅ **Like System**: Like/unlike reels
- ✅ **View Counter**: Hitung views otomatis
- ✅ **Caption Support**: Tambahkan caption pada reels

### 📦 Files Created

1. `supabase_migration_reels.sql` - Database migration
2. `lib/models/reel_model.dart` - Reel model
3. `lib/services/reel_service.dart` - Reel service
4. `lib/pages/create_reel_page.dart` - Create reel page

### 🔧 Files Modified

1. `lib/pages/create_post_page.dart` - Tambah tombol "Create Reel"
2. `lib/pages/reels_page.dart` - Load reels dari database
3. `lib/widgets/reel_item.dart` - Handle real data
4. `pubspec.yaml` - Tambah dependencies

### ⚙️ Technical Details

**Video Compression Settings:**
- Quality: Medium
- Audio: Included
- Format: Support semua format dari gallery

**Storage Structure:**
```
videos/
├── reels/
│   └── reel_[timestamp]_[filename].mp4
└── thumbnails/
    └── thumbnail_[timestamp].jpg
```

### 🎬 Demo Flow

```
User Flow:
1. Open Create Post Page
2. Click "Create Reel" button
3. Select video (any duration)
4. ⚡ Auto trim to 10s if needed
5. ⚡ Auto compress
6. Add caption
7. Upload to Supabase
8. View in Reels page
```

### 📝 Notes

- Pastikan bucket `videos` sudah pu-trim ke 10 detik pertama
- Compression berjalan otomatis saat upload
- Thumbnail di-generate dari frame pertama

### 🆘 Troubleshooting

**Video gagal upload?**
- Check apakah bucket `videos` sudah dibuat
- Pastikan bucket adalah public
- Video akan otomatis di-trim jika > 10 detik

**Compression lama?**
- Normal, tergantung ukuran video
- Video besar atau trimgantung ukuran video
- Video besar akan butuh waktu lebih lama

**Thumbnail tidak muncul?**
- Check apakah ada error di console
- Pastikan folder thumbnails accessible

---

For detailed setup: Lihat `SETUP_REELS.md`
